import 'package:equatable/equatable.dart';

abstract class PaymentState{
  const PaymentState();
}

class PaymentInitial extends PaymentState {

  
}

class PaymentLoading extends PaymentState {

}

class PaymentSuccess extends PaymentState {

}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

} 