import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/pages/opciones/sign_up.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class BlurScreenPosts extends StatefulWidget {
  const BlurScreenPosts({super.key});

  @override
  State<BlurScreenPosts> createState() => _BlurScreenState();
}

class _BlurScreenState extends State<BlurScreenPosts> {
  bool lang = true;
  Future<void> getLang() async {
    bool savedLang = await getLanguagePreference();
    setState(() {
      lang = savedLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: Stack(
            children: [
              const AddPostBlur(),
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
                  child: Text(
                      lang
                          ? 'Inicia sesion para utilizar esta funcion'
                          : 'Log in to use this function',
                      style: const TextStyle(
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

class AddPostBlur extends StatefulWidget {
  const AddPostBlur({super.key});

  @override
  State<AddPostBlur> createState() => _AddPostState();
}

class _AddPostState extends State<AddPostBlur> {
  TextEditingController descriptionController = TextEditingController(text: "");

  bool isToggled = false;
  String type = 'Extravio';
  String isToggledText() {
    isToggled ? type = 'Extravio' : type = 'Adopcion';
    return type;
  }

  final bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    const titleW(
                      title: 'Post',
                    ),
                    Positioned(
                        left: 30,
                        top: 70,
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios,
                                  size: 30, color: Colors.black),
                            ),
                            const Text(
                              'Back',
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 90,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: isToggled
                                    ? const Color.fromARGB(100, 169, 200, 149)
                                    : const Color.fromARGB(255, 169, 200, 149),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeIn,
                                    left: isToggled ? 50 : 0,
                                    right: isToggled ? 0 : 50,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        FontAwesomeIcons.heart,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            isToggledText(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: const PhotoCarousel(imageUrls: []),
                        onTap: () {},
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 250,
                        child: TextField(
                            controller: descriptionController,
                            maxLines: 6,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _isLoading
                          ? const SpinKitSpinningLines(
                              color: Color.fromRGBO(169, 200, 149, 1),
                              size: 50.0)
                          : OutlinedButton(
                              onPressed: () {},
                              style: customOutlinedButtonStyle(),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    'Post',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 20),
                                  ),
                                ],
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
