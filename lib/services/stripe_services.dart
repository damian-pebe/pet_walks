import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:petwalks_app/env.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment(BuildContext context) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(100, 'mxn');

      if (paymentIntentClientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              merchantDisplayName: 'PetWalks Enterprise'));

      await _processPayment(context);
    } catch (e) {
      _navigateToStatusScreen(context, 'Error', e.toString());
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

  Future<void> _processPayment(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      _navigateToStatusScreen(
          context, 'Success', 'Payment completed successfully!');
    } catch (e) {
      _navigateToStatusScreen(context, 'Error', e.toString());
    }
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString();
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

      await _processPayment(context);
    } catch (e) {
      _navigateToStatusScreen(context, 'Error', e.toString());
    }
  }

  void _navigateToStatusScreen(
      BuildContext context, String status, String message) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         PaymentStatusScreen(status: status, message: message),
    //   ),
    // );
  }
}



// import 'package:flutter/material.dart';
// import 'package:petwalks_app/services/firebase_services.dart';
// import 'package:petwalks_app/widgets/decorations.dart';

// class Premium extends StatefulWidget {
//   const Premium({super.key});

//   @override
//   State<Premium> createState() => _PremiumState();
// }

// class _PremiumState extends State<Premium> {
//   @override
//   void initState() {
//     super.initState();
//     _getLanguage();
//   }

//   bool? lang;
//   void _getLanguage() async {
//     lang = await getLanguage();
//     if (mounted) setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           scaffoldBackgroundColor: Colors.black,
//         ),
//         home: Scaffold(
//           body: lang == null
//               ? const CircularProgressIndicator(
//                   color: Colors.white,
//                 )
//               : Stack(
//                   children: [
//                     Image.asset(
//                       'assets/premium_background.jpg',
//                       width: double.infinity,
//                       fit: BoxFit.fill,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(40.0),
//                               child: Text(
//                                 lang!
//                                     ? 'Esta es la suscripción mensual a Pet Walks Premium por 29 MXN'
//                                     : 'This is the montlhy subscription to Pet Walks Premium for 29 MXN',
//                                 style: TextStyle(
//                                     fontSize: 25,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white),
//                               ),
//                             ),
//                             Image.asset(
//                               'assets/premium.png',
//                               height: 300,
//                               fit: BoxFit.fill,
//                             ),
//                             OutlinedButton(
//                               onPressed: () {},
//                               style: customOutlinedButtonStyle(),
//                               child: Text(
//                                 lang!
//                                     ? 'Comprar PetWalks Premium'
//                                     : 'Buy PetWalks Premium',
//                                 style: const TextStyle(color: Colors.black),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//         ));
//   }
// }
