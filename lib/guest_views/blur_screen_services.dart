import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/pages/opciones/sign_up.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class BlurScreenServices extends StatefulWidget {
  const BlurScreenServices({super.key});

  @override
  State<BlurScreenServices> createState() => _BlurScreenState();
}

class _BlurScreenState extends State<BlurScreenServices> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: Stack(
            children: [
              const ServiciosBlur(),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Sign_Up(),
                    ),
                  ),
                  child: const Text('Log in to use this function',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          color: Colors.black)),
                ),
              )
            ],
          ),
        ));
  }
}

class ServiciosBlur extends StatefulWidget {
  const ServiciosBlur({super.key});

  @override
  State<ServiciosBlur> createState() => _ServiciosState();
}

class _ServiciosState extends State<ServiciosBlur> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: Column(
            children: [
              const titleW(title: 'Services'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            alignment: Alignment.topRight,
                            child: OutlinedButton(
                                onPressed: () async {},
                                style: customOutlinedButtonStyle(),
                                child: const Icon(
                                  FontAwesomeIcons.slidersH,
                                  size: 30,
                                  color: Colors.black,
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Column(
                          children: [
                            OutlinedButton(
                                onPressed: () {},
                                style: customOutlinedButtonStyle(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.dog,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Request walk',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 25.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            OutlinedButton(
                                onPressed: () {},
                                style: customOutlinedButtonStyle(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.walking,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Walk pets',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 25.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            OutlinedButton(
                                onPressed: () {},
                                style: customOutlinedButtonStyle(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      Icons.add_business_rounded,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Business',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 25.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                        Image.asset(
                          'assets/logo.png',
                          width: 230,
                          height: 230,
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ));
  }
}
