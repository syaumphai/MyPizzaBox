part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class PlaceOrder extends OrderEvent {
  final List<Pizza> items;
  final Map<String, int> quantities;
  final double total;

  const PlaceOrder({
    required this.items,
    required this.quantities,
    required this.total,
  });

  @override
  List<Object?> get props => [items, quantities, total];
}
