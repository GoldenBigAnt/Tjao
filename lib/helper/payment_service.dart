
import 'dart:convert';

import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentIntentURL = apiBase + '/payment_intents';
  static String secret = 'sk_test_51IMtJxI16DmSxJkvwQknNFV0D9EmrvOr4d7ORlaRqpifrPMpXNmU8ljtY8HUL8mc4uGJlrMMxEYc3xKhbqDAmh9j004qUmY4od';
  static Map<String, String> headers = {
    'Authorization': 'Bearer $secret',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static init() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "pk_test_51IMtJxI16DmSxJkv0rXBUoLSjZ6qyX4vR5GlPtui9qges5DRV8cCxCzzsQledOhwuy8wqQkd9Fa3iDFkV1auZVdg00eJ8EEVPZ",
        merchantId: "Test",
        androidPayMode: 'test'
      )
    );
  }

  static Future<StripeTransactionResponse>  payViaExistingCard({String amount, String currency, card}) async {
    CreditCard testCard = CreditCard(
      number: card['cardNumber'],
      expMonth: int.parse(card['expiryDate'].toString().split('/')[0]),
      expYear: int.parse(card['expiryDate'].toString().split('/')[1]),
    );
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: testCard
        )
      );
      var paymentIntent = await StripeService.createPaymentIntent(amount, currency);
      print(['client secret: ', paymentIntent['client_secret']]);

      var response = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              clientSecret: paymentIntent['client_secret'],
              paymentMethodId: paymentMethod.id
          )
      );

      if(response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true
        );
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed',
            success: false
        );
      }
    } catch(err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false
      );
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard({String amount, String currency, card}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest()
      );
      print(['payment method: ', json.encode(paymentMethod)]);

      var paymentIntent = await StripeService.createPaymentIntent(amount, currency);
      print(['client secret: ', paymentIntent['client_secret']]);

      var response = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id
        )
      );

      if(response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true
        );
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed',
            success: false
        );
      }
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false
      );
    }

  }

  static  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
        paymentIntentURL,
        body: body,
        headers: headers
      );
      return json.decode(response.body);
    } catch (err) {
      print('charging error: ${err.toString()}');
    }
  }
}