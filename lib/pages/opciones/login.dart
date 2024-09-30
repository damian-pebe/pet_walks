import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/sign_up.dart';
import 'package:petwalks_app/services/auth_service.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  void _resetPassword(String email) async {
    if (email.isNotEmpty) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
  }

  bool lang = true;
  Future<void> getLang() async {
    bool savedLang = await getLanguagePreference();
    setState(() {
      lang = savedLang;
    });
  }

  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  String encryptedPassword = '';
  final _auth = AuthService();
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      await getAndAddTokenToArray();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Funcion(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      var msg = '';
      switch (e.code) {
        case 'invalid-email':
          msg = 'Correo electronico invalido';
          break;
        case 'user-disabled':
          msg = 'Usuario no disponible';
          break;
        case 'user-not-found':
          msg = 'Uusuario no encontrado';

          break;
        case 'wrong-password':
          msg = 'Contraseña incorrecta';

          break;
      }

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error al iniciar sesion'),
              content: Text(msg),
            );
          });
    }
  }

  String? email;

  Future<void> logInWithGoogle() async {
    await _auth.logInGoogle();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      email = user.email ?? 'There was a problem fetching the info';
      await newUser('', email!, '', '');
      await getAndAddTokenToArray();
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

  bool verifyFieldsEmail() {
    if (emailController.text == "") return false;
    return true;
  }

  bool verifyFieldsPasswords() {
    if (passwordController.text == '') return false;

    // final encrypted = encrypter.encrypt(passwordController.text, iv: iv);
    // setState(() {
    //   encryptedPassword = encrypted.base64;
    // });
    return true;
  }

  bool verifyFields() {
    if (!verifyFieldsEmail()) return false;
    if (!verifyFieldsPasswords()) return false;

    return true;
  }

  // final key = encrypt.Key.fromUtf8('my 32 length key................');
  // final iv = encrypt.IV.fromLength(16);
  // final encrypter = encrypt.Encrypter(
  //     encrypt.AES(encrypt.Key.fromUtf8('my 32 length key................')));

  bool _isEmail = true;
  bool _isPassword = true;

  @override
  void initState() {
    getLang();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Funcion()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: SingleChildScrollView(
              child: Column(
            children: [
              Stack(
                children: [
                  titleW(
                    title: lang ? 'Iniciar sesion' : 'Log in',
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
                          Text(
                            lang ? 'Regresar' : 'Back',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      )),
                ],
              ),
              Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang ? 'Hola de nuevo!' : 'Hi, welcome again!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: StyleTextField('Email')),
                        Visibility(
                          visible: !_isEmail,
                          child: Text(
                            lang
                                ? '* Falta email del usuario'
                                : '* Missing user\'s email',
                            style: TextStyle(color: Colors.red, fontSize: 10),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                            obscureText: _obscureText,
                            controller: passwordController,
                            decoration: StyleTextField(
                              lang ? 'Contraseña' : 'Password',
                            )),
                        Visibility(
                          visible: !_isPassword,
                          child: Text(
                            lang
                                ? '* Las contraseñas ingresadas no son validas o no coinciden'
                                : '* Invalid or different passwords',
                            style: TextStyle(color: Colors.red, fontSize: 10),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 40,
                          width: 300,
                          child: OutlinedButton(
                            onPressed: () {
                              _resetPassword(emailController.text);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Color.fromRGBO(250, 244, 229, 1),
                                  width: 2),
                            ),
                            child: Text(
                              lang
                                  ? '¿Olvido su contraseña?\nLlene el campo email y de click aqui!'
                                  : 'Forgot password?\nComplete the Email field and click here',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        OutlinedButton(
                            onPressed: () {
                              if (!verifyFields()) {
                                if (!verifyFieldsEmail()) {
                                  _isEmail = false;
                                  setState(() {});
                                } else {
                                  _isEmail = true;
                                  setState(() {});
                                }
                                if (!verifyFieldsPasswords()) {
                                  _isPassword = false;
                                  setState(() {});
                                } else {
                                  _isPassword = true;
                                  setState(() {});
                                }
                              } else {
                                _isEmail = true;
                                _isPassword = true;

                                _login();
                              }
                            },
                            style: customOutlinedButtonStyle(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.user,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  lang ? 'Iniciar sesion' : 'Log in',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 20),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        OutlinedButton(
                            onPressed: () async {
                              await logInWithGoogle();
                            },
                            style: customOutlinedButtonStyle(),
                            child: Image.asset(
                              'assets/google.png',
                              width: 40,
                              height: 40,
                            )),
                        SizedBox(
                          height: 30,
                          width: 300,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Sign_Up(),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Color.fromRGBO(250, 244, 229, 1),
                                  width: 2),
                            ),
                            child: Text(
                              lang
                                  ? '¿No tienes cuenta? Registrate aqui!'
                                  : 'Don\'t have an account? Register here!',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/logo.png',
                          width: 230,
                          height: 230,
                        ),
                      ])),
            ],
          )),
        ));
  }
}
