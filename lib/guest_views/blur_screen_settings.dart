import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/pages/opciones/sign_up.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class BlurScreenSettings extends StatefulWidget {
  const BlurScreenSettings({super.key});

  @override
  State<BlurScreenSettings> createState() => _BlurScreenState();
}

class _BlurScreenState extends State<BlurScreenSettings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: Stack(
            children: [
              const AjustesBlur(),
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

class AjustesBlur extends StatefulWidget {
  const AjustesBlur({super.key});

  @override
  State<AjustesBlur> createState() => _AjustesState();
}

class _AjustesState extends State<AjustesBlur> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: Column(
            children: [
              const titleW(title: 'Configuration'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const EmptyBox(w: 0, h: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 24.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Language',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.language_outlined,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: SizedBox(
                              height: 40,
                              child: Image.asset(
                                'assets/eu.png',
                                fit: BoxFit.cover,
                                height: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Language',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.account_circle_outlined,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      const EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Manage pets',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                FontAwesomeIcons.dog,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      const EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () async {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Usage tutorial',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.video_camera_front_outlined,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      const EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () async {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'About us',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.perm_identity,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      const EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () async {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Suggestions',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.send,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      const EmptyBox(w: 0, h: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.workspace_premium,
                                  size: 35,
                                  color: Colors.black,
                                ),
                              ),
                              const Text(
                                'Premium',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.logout_outlined,
                                  size: 35,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Log out',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
