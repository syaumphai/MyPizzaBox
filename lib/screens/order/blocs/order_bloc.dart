import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<PlaceOrder>((event, emit) async {
      emit(OrderPlacing());
      // Simulate order placement
      await Future.delayed(const Duration(seconds: 1));
      emit(OrderPlaced());
    });
  }
}
