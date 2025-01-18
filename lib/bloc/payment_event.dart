import 'package:equatable/equatable.dart';
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
}

class InitiatePaymentEvent extends PaymentEvent {
  final String username;
  final String token;
  final String feature;
  final Function postPayment;
  final String? sessionId;
  final Map<String,dynamic>? createdOrder;

   InitiatePaymentEvent({
    required this.username,
    required this.token,
    required this.feature,
    required this.postPayment,
    this.sessionId,
    this.createdOrder
  });

  @override
  List<Object> get props => [username, token, feature, postPayment,sessionId??"",createdOrder??{}];
} 