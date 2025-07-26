import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_app/screens/order/repositories/order_tracking_repository.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivering,
  delivered,
  cancelled,
}

class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderTracking extends OrderTrackingEvent {
  final String orderId;

  const LoadOrderTracking(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatus extends OrderTrackingEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatus(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class OrderTrackingState extends Equatable {
  const OrderTrackingState();

  @override
  List<Object?> get props => [];
}

class OrderTrackingInitial extends OrderTrackingState {}

class OrderTrackingLoading extends OrderTrackingState {}

class OrderTrackingLoaded extends OrderTrackingState {
  final String orderId;
  final OrderStatus currentStatus;
  final List<OrderStatus> statusHistory;
  final DateTime estimatedDeliveryTime;
  final String? driverName;
  final String? driverPhone;
  final double? driverLatitude;
  final double? driverLongitude;

  const OrderTrackingLoaded({
    required this.orderId,
    required this.currentStatus,
    required this.statusHistory,
    required this.estimatedDeliveryTime,
    this.driverName,
    this.driverPhone,
    this.driverLatitude,
    this.driverLongitude,
  });

  @override
  List<Object?> get props => [
        orderId,
        currentStatus,
        statusHistory,
        estimatedDeliveryTime,
        driverName,
        driverPhone,
        driverLatitude,
        driverLongitude,
      ];

  OrderTrackingLoaded copyWith({
    String? orderId,
    OrderStatus? currentStatus,
    List<OrderStatus>? statusHistory,
    DateTime? estimatedDeliveryTime,
    String? driverName,
    String? driverPhone,
    double? driverLatitude,
    double? driverLongitude,
  }) {
    return OrderTrackingLoaded(
      orderId: orderId ?? this.orderId,
      currentStatus: currentStatus ?? this.currentStatus,
      statusHistory: statusHistory ?? this.statusHistory,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
    );
  }
}

class OrderTrackingError extends OrderTrackingState {
  final String message;

  const OrderTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final OrderTrackingRepository _repository;

  OrderTrackingBloc({OrderTrackingRepository? repository})
      : _repository = repository ?? OrderTrackingRepository(),
        super(OrderTrackingInitial()) {
    on<LoadOrderTracking>(_onLoadOrderTracking);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  void _onLoadOrderTracking(
    LoadOrderTracking event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(OrderTrackingLoading());

    try {
      final orderData = await _repository.getOrderTracking(event.orderId);

      if (orderData != null) {
        final status = _stringToOrderStatus(orderData['status'] ?? 'pending');
        final statusHistory = (orderData['statusHistory'] as List<dynamic>?)
                ?.map((s) => _stringToOrderStatus(s.toString()))
                .toList() ??
            [OrderStatus.pending];

        final estimatedDeliveryTime = orderData['estimatedDeliveryTime'] != null
            ? (orderData['estimatedDeliveryTime'] as Timestamp).toDate()
            : DateTime.now().add(const Duration(minutes: 45));

        emit(OrderTrackingLoaded(
          orderId: orderData['orderId'],
          currentStatus: status,
          statusHistory: statusHistory,
          estimatedDeliveryTime: estimatedDeliveryTime,
          driverName: orderData['driverName'],
          driverPhone: orderData['driverPhone'],
          driverLatitude: orderData['driverLatitude']?.toDouble(),
          driverLongitude: orderData['driverLongitude']?.toDouble(),
        ));
      } else {
        emit(const OrderTrackingError('ບໍ່ພົບຂໍ້ມູນອອເດີ'));
      }
    } catch (e) {
      emit(OrderTrackingError('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນການຕິດຕາມໄດ້: $e'));
    }
  }

  OrderStatus _stringToOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.delivering:
        return 'delivering';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  void _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderTrackingState> emit,
  ) async {
    if (state is OrderTrackingLoaded) {
      final currentState = state as OrderTrackingLoaded;

      try {
        await _repository.updateOrderStatus(
            event.orderId, _orderStatusToString(event.status));

        final newStatusHistory =
            List<OrderStatus>.from(currentState.statusHistory);
        if (!newStatusHistory.contains(event.status)) {
          newStatusHistory.add(event.status);
        }

        emit(currentState.copyWith(
          currentStatus: event.status,
          statusHistory: newStatusHistory,
        ));
      } catch (e) {
        emit(OrderTrackingError('ບໍ່ສາມາດອັບເດດສະຖານະໄດ້: $e'));
      }
    }
  }
}
 