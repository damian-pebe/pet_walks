import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({super.key});

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
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
        scaffoldBackgroundColor: Color.fromARGB(255, 176, 183, 194),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/success.jpg',
              fit: BoxFit.fitHeight,
              height: double.infinity,
            ),
            lang == null
                ? const SpinKitSpinningLines(
                    color: Color.fromRGBO(0, 0, 0, 1), size: 50.0)
                : Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          lang!
                              ? 'Su pago se ha realizado con exito, gracias por utilizar PetWalks'
                              : 'Your payment has been made successfully, thank you for using PetWalks',
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        Image.asset(
                          'assets/thanku.jpg',
                          height: 300,
                          fit: BoxFit.fill,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(
                                Icons.arrow_back_ios_new_sharp,
                                color: Colors.black,
                              ),
                              Text(
                                lang!
                                    ? 'Salir a historial'
                                    : 'Go back to history',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
