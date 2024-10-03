import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/guest_views/funcion_guest.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/login.dart';
import 'package:petwalks_app/services/auth_service.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'sign_up.dart';

class Opciones extends StatefulWidget {
  const Opciones({super.key});

  @override
  State<Opciones> createState() => _OpcionesState();
}

class _OpcionesState extends State<Opciones> {
  bool lang = true;

  @override
  void initState() {
    super.initState();
    getLang();
  }

  Future<void> getLang() async {
    bool savedLang = await getLanguagePreference();
    setState(() {
      lang = savedLang;
    });
  }

  Future<void> saveLang(bool langValue) async {
    await saveLanguagePreference(langValue);
  }

  final _auth = AuthService();
  String? email;

  Future<void> logInWithGoogle() async {
    await _auth.logInGoogle();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      email = user.email ?? 'There was a problem fetching the info';
      await newUser('', email!, '', '');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Funcion()),
        );
      } else {}
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      ),
      home: Scaffold(
        body: Column(
          children: [
            const titleW(title: 'Pet Walks'),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5),
                      Image.asset(
                        'assets/logo.png',
                        width: 260,
                        height: 260,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogIn(),
                            ),
                          );
                        },
                        style: customOutlinedButtonStyle(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              FontAwesomeIcons.user,
                              size: 23,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 30),
                            Text(
                              lang ? 'Iniciar sesión' : '  Log in  ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'o',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Sign_Up(),
                              ));
                        },
                        style: customOutlinedButtonStyle(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.logout_outlined,
                              size: 25,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 30),
                            Text(
                              lang ? 'Registrarme' : '  Sign up  ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () => logInWithGoogle(),
                        style: customOutlinedButtonStyle(),
                        child: Image.asset(
                          'assets/google.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FuncionGuest(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color.fromRGBO(250, 244, 229, 1),
                              width: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 30),
                        ),
                        child: Text(
                          lang ? 'Ingresar como invitado' : 'View as guest',
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 15,
                              color: Colors.black),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang ? 'Idioma' : 'Language',
                                  style: const TextStyle(
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
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.language_outlined,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              saveLang(!lang); // Toggle language
                              setState(() {
                                lang = !lang;
                              });
                            },
                            child: SizedBox(
                              height: 40,
                              child: Image.asset(
                                lang ? 'assets/mexico.png' : 'assets/eu.png',
                                fit: BoxFit.cover,
                                height: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
