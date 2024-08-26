import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/funcion.dart';
import 'package:petwalks_app/pages/opciones/login.dart';
import 'package:petwalks_app/services/auth_service.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'registro.dart';

class Opciones extends StatefulWidget {
  const Opciones({super.key});

  @override
  State<Opciones> createState() => _OpcionesState();
}

class _OpcionesState extends State<Opciones> {
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
      } else {
        print('The widget is no longer mounted.');
      }
    } else {
      print('Error: No user found after Google login');
    }
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
            titleW(title: 'Pet Walks'),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogIn(),
                          ),
                        ),
                        style: customOutlinedButtonStyle(),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.user,
                              size: 23,
                              color: Colors.black,
                            ),
                            SizedBox(width: 30),
                            Text(
                              'Iniciar sesión',
                              style: TextStyle(
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
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Sign_Up(),
                          ),
                        ),
                        style: customOutlinedButtonStyle(),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              size: 25,
                              color: Colors.black,
                            ),
                            SizedBox(width: 30),
                            Text(
                              'Registrarme',
                              style: TextStyle(
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
                          width: 40,
                          height: 40,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LogIn(), // MODIFICAR PARA INVITADO
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color.fromRGBO(250, 244, 229, 1),
                              width: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 30),
                        ),
                        child: const Text(
                          'Ingresar como invitado',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 15,
                              color: Colors.black),
                        ),
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
