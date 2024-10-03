import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/services/stripe_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';

class Premium extends StatefulWidget {
  const Premium({super.key});

  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  @override
  void initState() {
    super.initState();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: Scaffold(
          body: lang == null
              ? const SpinKitSpinningLines(
                  color: Color.fromRGBO(255, 255, 255, 1), size: 50.0)
              : Stack(
                  children: [
                    Image.asset(
                      'assets/premium_background.jpg',
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                        left: 10,
                        top: 40,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios,
                              size: 30, color: Colors.white),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Text(
                                lang!
                                    ? 'Esta es la suscripción mensual a Pet Walks Premium por 29 MXN'
                                    : 'This is the montlhy subscription to Pet Walks Premium for 29 MXN',
                                // ignore: prefer_const_constructors
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Image.asset(
                              'assets/premium.png',
                              height: 300,
                              fit: BoxFit.fill,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                StripeService.instance
                                    .makePaymentPremium(context);
                              },
                              style: customOutlinedButtonStyle(),
                              child: Text(
                                lang!
                                    ? 'Comprar PetWalks Premium'
                                    : 'Buy PetWalks Premium',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        ));
  }
}
