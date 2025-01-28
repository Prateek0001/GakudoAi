import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_logix/bloc/booking_event.dart';
import 'package:rx_logix/bloc/booking_state.dart';
import 'package:rx_logix/repositories/auth/auth_repository_impl.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rx_logix/models/postPaymentPayload.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<InitiatePaymentEvent>(_onInitiatePayment);
  }

  Future<void> _onInitiatePayment(InitiatePaymentEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      if(event.feature!='session'){
            final   paymentStatus = await AuthRepositoryImpl().getPaymentStatus(event.username, event.token,event.feature);
 if (paymentStatus) {
        event.postPayment();
      } else {
        final createdOrder = await AuthRepositoryImpl().createOrder(event.username, event.token, event.feature);
        if (createdOrder.isNotEmpty) {
          String orderId = createdOrder['order_id']; // Replace with actual order ID
          int actAmount = createdOrder['amount']*100; // actual amount in paise
          int discAmount = createdOrder['amount_due']*100; // discount amount in paise

          Razorpay razorpay = Razorpay();
          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
            if(response.orderId!=null&&response.paymentId!=null&&response.signature!=null){
            final postResponse = await AuthRepositoryImpl().postPayment(
              event.token,
              PostPaymentPayload(
                actAmount: actAmount,
                feature: event.feature,
                razorpayOrderId: response.orderId,
                razorpayPaymentId: response.paymentId,
                username: event.username,
                razorpaySignature: response.signature ?? "",
                discAmount: discAmount,sessionId: event.sessionId??""
              ),
            );
            if (postResponse==true) {
              event.postPayment();
              emit(PaymentSuccess());
            }else{
              emit(PaymentError("Payment failed"));
            }
          }else{
            emit(PaymentError("Payment failed"));
          }
          });

          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse error) {
            emit(PaymentError(error.message ?? "Payment failed"));
          });

          razorpay.open({
                    'key': createdOrder['rzp_id'],
                    'amount': discAmount,
                    'name': 'GakudoAi',
                    'description': 'Payment for Order #$orderId',
                    'retry': {'enabled': true, 'max_count': 1},
                    'send_sms_hash': true,
                    'external': {
                      'wallets': ['paytm']
                    }
                  });
        
        }
      }
      }else{
         if (event.createdOrder!=null&&event.createdOrder?.isNotEmpty==true) {
          String orderId = event.createdOrder?['order_id']; // Replace with actual order ID
          int actAmount = event.createdOrder?['amount']; // actual amount in paise
          int discAmount = event.createdOrder?['amount_due']; // discount amount in paise

          Razorpay razorpay = Razorpay();
          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
            if(response.orderId!=null&&response.paymentId!=null&&response.signature!=null){
            final postResponse = await AuthRepositoryImpl().postPayment(
              event.token,
              PostPaymentPayload(
                actAmount: actAmount,
                feature: event.feature,
                razorpayOrderId: response.orderId,
                razorpayPaymentId: response.paymentId,
                username: event.username,
                razorpaySignature: response.signature ?? "",
                discAmount: discAmount,sessionId: event.sessionId??""
              ),
            );
            if (postResponse==true) {
              await event.postPayment();
              emit(PaymentSuccess());
            }else{
              emit(PaymentError("Payment failed"));
            }
          }else{
            emit(PaymentError("Payment failed"));
          }
          });

          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse error) {
            emit(PaymentError(error.message ?? "Payment failed"));
          });

          razorpay.open({
                    'key': event.createdOrder?['rzp_id'],
                    'amount': discAmount,
                    'order_id': orderId,
                    'name': 'GakudoAi',
                    'description': 'Payment for Order #$orderId',
                    'retry': {'enabled': true, 'max_count': 1},
                    'send_sms_hash': true,
                    'external': {
                      'wallets': ['paytm']
                    }
                  });
        
      }
      }
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
} 