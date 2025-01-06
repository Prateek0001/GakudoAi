// To parse this JSON data, do
//
//     final PostPaymentPayload = PostPaymentPayloadFromJson(jsonString);

import 'dart:convert';

PostPaymentPayload PostPaymentPayloadFromJson(String str) => PostPaymentPayload.fromJson(json.decode(str));

String PostPaymentPayloadToJson(PostPaymentPayload data) => json.encode(data.toJson());

class PostPaymentPayload {
    String? username;
    String? feature;
    String? sessionId;
    int? actAmount;
    int? discAmount;
    String? razorpayOrderId;
    String? razorpayPaymentId;
    String? razorpaySignature;

    PostPaymentPayload({
        this.username,
        this.feature,
        this.sessionId,
        this.actAmount,
        this.discAmount,
        this.razorpayOrderId,
        this.razorpayPaymentId,
        this.razorpaySignature,
    });

    factory PostPaymentPayload.fromJson(Map<String, dynamic> json) => PostPaymentPayload(
        username: json["username"],
        feature: json["feature"],
        sessionId: json["session_id"]??"",
        actAmount: json["act_amount"],
        discAmount: json["disc_amount"],
        razorpayOrderId: json["razorpay_order_id"],
        razorpayPaymentId: json["razorpay_payment_id"],
        razorpaySignature: json["razorpay_signature"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "feature": feature,
        "session_id": sessionId??"",
        "act_amount": actAmount,
        "disc_amount": discAmount,
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_signature": razorpaySignature,
    };
}
