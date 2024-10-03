// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/init_app/servicios/requests/payment_status.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/toast.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment(
      BuildContext context, int price, String idHistory) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(price, 'mxn');

      if (paymentIntentClientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              merchantDisplayName: 'PetWalks Enterprise'));

      await _processPayment(context, idHistory);
    } catch (e) {
      _navigateToStatusScreen(
        context,
        'Error',
        null,
      );
    }
  }

  Future<void> _processPayment(BuildContext context, String? idHistory) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      _navigateToStatusScreen(
        context,
        'Success',
        idHistory,
      );
    } catch (e) {
      _navigateToStatusScreen(
        context,
        'Error',
        null,
      );
    }
  }

  Future<void> makePaymentPremium(BuildContext context) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(29, 'mxn');

      if (paymentIntentClientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        merchantDisplayName: 'PetWalks Enterprise',
      ));

      await _processPayment(context, null);
    } catch (e) {
      _navigateToStatusScreen(context, 'Error', null);
    }
  }

  Future<void> _navigateToStatusScreen(
      BuildContext context, String status, String? idHistory) async {
    if (status == 'Error') {
      toastF('Error processing payment, please try again');
    } else {
      await updateHistoryPaymentStatus(idHistory);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PaymentSuccess()),
      );
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();

      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
        "description": 'description'
      };
      var response = await dio.post('https://api.stripe.com/v1/payment_intents',
          data: data,
          options:
              Options(contentType: Headers.formUrlEncodedContentType, headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          }));

      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString();
  }
}
