// ignore_for_file: camel_case_types, empty_catches, use_build_context_synchronously

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/home/editHome.dart';
import 'package:petwalks_app/pages/opciones/home/selectHome.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/pages/opciones/login.dart';
import 'package:petwalks_app/services/twilio.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';
import 'package:petwalks_app/widgets/visibility.dart';

class Sign_Up extends StatefulWidget {
  const Sign_Up({super.key});

  @override
  State<Sign_Up> createState() => _Sign_UpState();
}

class _Sign_UpState extends State<Sign_Up> {
//!TEXTBELT KEY ONLY ONE PER DAY ON FREE TIER

  late final TwilioService twilioService;

  bool lang = true;
  Future<void> getLang() async {
    bool savedLang = await getLanguagePreference();
    setState(() {
      lang = savedLang;
    });
  }

  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController homeController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController verifyPasswordController =
      TextEditingController(text: "");

  TextEditingController tokenController = TextEditingController(text: "");
  //token phone verification == 4 digits
  bool verificationModule = false;

  String homelatlng = '';

  final _auth = FirebaseAuth.instance;

  Future<User?> signUpWithCred(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {}
    return null;
  }

  bool isVerified = false;
  IconData getIcon() {
    return isVerified ? Icons.verified_outlined : Icons.error_outline;
  }

  bool isPrivacity = false;
  IconData getIconPrivacity() {
    setState(() {});
    return isPrivacity ? Icons.check : Icons.not_interested;
  }

  bool enablePhone = true;
  void verifyPhone(String numberPhone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang
                    ? 'Verificar su numero de telefono'
                    : 'Verify phone number',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              const Icon(
                Icons.send,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
          backgroundColor: const Color.fromRGBO(250, 244, 229, 1),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: tokenController,
                      decoration: StyleTextField(
                        lang ? 'Token' : 'Token',
                      )),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () {
                      if (sameToken(tokenController.text)) {
                        verificationModule = true;
                        toastF(
                          lang
                              ? 'Telefono verificado con exito'
                              : 'Phone number verified',
                        );
                      } else {
                        toastF(
                          lang
                              ? '* El token enviado no coincide'
                              : 'Invalid token',
                        );
                      }
                      Navigator.pop(context, verificationModule);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(width: 2.0, color: Colors.black),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Colors.black,
                        ),
                        Text(
                          lang ? 'Verificar' : 'Verify',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: !_isSame,
              child: Text(
                lang ? '* El token enviado no coincide' : 'Invalid token',
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                //!enviar token
                String phone = phoneController.text;
                String message =
                    'PET WALKS, Token de verificacion para: ${phoneController.text}\nSu token de verificacion es: $tokenKey';
                twilioService.sendSms(phone, message);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color.fromRGBO(250, 244, 229, .65), width: 2),
              ),
              child: Text(
                lang
                    ? 'Enviar token de verificacion'
                    : 'Send verification token',
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                    color: Colors.black),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context, false);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color.fromRGBO(250, 244, 229, .65), width: 2),
              ),
              child: Text(
                lang ? 'Salir' : 'Back',
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
            ),
          ],
        );
      },
    ).then((verificationResult) {
      if (verificationResult == true) {
        setState(() {
          isVerified = true;
          enablePhone = false;
        });
      }
    });
  }

  bool sameToken(String sent) {
    if (tokenKey != sent) return false;

    return true;
  }

  bool verifyFieldsName() {
    if (nameController.text == "") return false;
    if (emailController.text.length > 35) return false;

    return true;
  }

  bool verifyFieldsEmail() {
    if (emailController.text == "") return false;
    if (emailController.text.length > 75) return false;
    return true;
  }

  bool verifyFieldsHome() {
    if (homeController.text == "") return false;
    return true;
  }

  bool verifyFieldsPasswords() {
    String password = passwordController.text;
    String verifyPassword = verifyPasswordController.text;
    if (password.isEmpty || verifyPassword.isEmpty) return false;
    if (password != verifyPassword) return false;
    if (password.length < 8) return false;
    if (password.length > 20) return false;
    final RegExp passwordRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    if (!passwordRegExp.hasMatch(password)) return false;

    return true;
  }

  bool verifyFields() {
    if (!verifyFieldsName()) return false;
    if (!verifyFieldsEmail()) return false;
    if (!isVerified) return false;
    if (!verifyFieldsHome()) return false;
    if (!verifyFieldsPasswords()) return false;

    return true;
  }

  bool _isName = true;
  bool _isEmail = true;
  bool _isHome = true;
  bool _isPassword = true;
  bool _isVerified = true;
  bool _isPrivacity = true;
  final _isSame = true;
  String? tokenKey;
  @override
  void initState() {
    getLang();
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // Signed in
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Funcion()),
          );
        }
      }
    });
    generateFourDigitToken();
    twilioService = twilioServiceKeys;
  }

  void generateFourDigitToken() {
    final random = Random();
    int number = 1000 + random.nextInt(9000);
    tokenKey = number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      titleW(
                        title: lang ? 'Registrarme' : 'Sign up',
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
                                style: const TextStyle(fontSize: 10),
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
                        TextField(
                            keyboardType: TextInputType.name,
                            controller: nameController,
                            decoration: StyleTextField(
                              lang ? 'Nombre' : 'Name',
                            )),
                        VisibilityW(
                          boolean: _isName,
                          string: lang
                              ? 'Falta nombre del usuario'
                              : 'Missing user name',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: StyleTextField('@email.com')),
                        Visibility(
                          visible: !_isEmail,
                          child: Text(
                            lang
                                ? '* Falta email del usuario'
                                : '* Missing user email',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextField(
                                  onChanged: (_) {
                                    setState(() {
                                      isVerified = false;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  controller: phoneController,
                                  decoration: StyleTextField(
                                    lang ? 'Telefono' : 'Phone number',
                                  )),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 90,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (isVerified) {
                                    toastF(
                                      lang
                                          ? 'Numero ya verificacdo'
                                          : 'Already verified',
                                    );

                                    return;
                                  }

                                  verifyPhone(phoneController.text);

                                  if (verificationModule) {
                                    isVerified = true;
                                    setState(() {});
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 0.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: const BorderSide(
                                        width: 2.0, color: Colors.black),
                                  ),
                                  backgroundColor: Colors.grey[200],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      getIcon(),
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      lang ? 'Verificacion' : 'Verification',
                                      style: const TextStyle(
                                          fontSize: 8, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Visibility(
                          visible: !_isVerified,
                          child: Text(
                            lang
                                ? '* Falta verificar telefono del usuario'
                                : '* Missing phone number verification',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                                //seleccionar domicilio
                                onPressed: () async {
                                  String domicilio = '';
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SelectHome(),
                                    ),
                                  );

                                  if (result != null) {
                                    domicilio = result['domicilio'];
                                  }
                                  setState(() {
                                    homeController.text = domicilio.toString();
                                  });
                                },
                                style: customOutlinedButtonStyle(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.home,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      lang ? 'Seleccionar' : 'Select',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            OutlinedButton(
                                //editar domicilio
                                onPressed: () async {
                                  if (homeController.text == '') {
                                    toast(lang
                                        ? 'Primero selecciona el domicilio para editar'
                                        : 'First select adress to edit');
                                  } else {
                                    //select edit

                                    String domicilio = '';
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditHome(
                                          homeToEdit: homeController.text,
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      domicilio = result['domicilio'];
                                    }
                                    setState(() {
                                      homeController.text =
                                          domicilio.toString();
                                    });
                                  }
                                },
                                style: customOutlinedButtonStyle(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      lang ? 'Editar' : 'Edit',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.edit,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Visibility(
                          visible: !_isHome,
                          child: Text(
                            lang
                                ? '* Falta seleccionar domicilio del usuario'
                                : '* Missing user address',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 24.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            lang
                                ? 'Domicilio: ${homeController.text}'
                                : 'Adress: ${homeController.text}',
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
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: StyleTextField(
                              lang ? 'Contraseña' : 'Password',
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                            obscureText: true,
                            controller: verifyPasswordController,
                            decoration: StyleTextField(
                              lang
                                  ? 'Confirmar contraseña'
                                  : 'Confirm password',
                            )),
                        Visibility(
                          visible: !_isPassword,
                          child: Text(
                            lang
                                ? '* Las contraseñas ingresadas no son validas o no coinciden'
                                : '* The passwords aren\'t valid or do not match',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 250,
                              child: OutlinedButton(
                                onPressed: () => showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    barrierColor:
                                        Colors.black.withOpacity(0.65),
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          lang
                                              ? 'Terminos y condiciones y politicas de privacidad'
                                              : 'Terms and conditions and privacy policies',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: Text(
                                          lang
                                              ? 'Terminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidad'
                                              : 'Terms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policiesTerms and conditions and privacy policies',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color.fromRGBO(250, 244, 229, 1),
                                      width: 2),
                                ),
                                child: Text(
                                  lang
                                      ? 'Acepto los terminos y condiciones de uso asi como las politicas de privacidad'
                                      : 'I accept the terms and conditions of use as well as the privacy policies',
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 13,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 70,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (isPrivacity) {
                                    toastF(
                                      lang
                                          ? 'Ya fueron aceptados'
                                          : 'Alreaady accepted',
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isPrivacity = !isPrivacity;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: const BorderSide(
                                        width: 2.0, color: Colors.black),
                                  ),
                                  backgroundColor: Colors.grey[200],
                                ),
                                child: Icon(
                                  getIconPrivacity(),
                                  color:
                                      isPrivacity ? Colors.green : Colors.red,
                                  size: 25,
                                ),
                              ),
                            )
                          ],
                        ),
                        Visibility(
                          visible: !_isPrivacity,
                          child: Text(
                            lang
                                ? '* Necesita aceptar los terminos y condiciones de uso asi como las politicas de privacidad'
                                : '* You need to accept the terms and conditions of use as well as the privacy policies',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        OutlinedButton(
                            onPressed: () {
                              if (!verifyFields()) {
                                if (!verifyFieldsName()) {
                                  _isName = false;
                                  setState(() {});
                                } else {
                                  _isName = true;
                                  setState(() {});
                                }
                                if (!verifyFieldsEmail()) {
                                  _isEmail = false;
                                  setState(() {});
                                } else {
                                  _isEmail = true;
                                  setState(() {});
                                }
                                if (!isVerified) {
                                  _isVerified = false;
                                  setState(() {});
                                } else {
                                  _isVerified = true;
                                  setState(() {});
                                }
                                if (!isPrivacity) {
                                  _isPrivacity = false;
                                  setState(() {});
                                } else {
                                  _isPrivacity = true;
                                  setState(() {});
                                }
                                if (!verifyFieldsHome()) {
                                  _isHome = false;
                                  setState(() {});
                                } else {
                                  _isHome = true;
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
                                _isName = true;
                                _isEmail = true;
                                _isVerified = true;
                                _isPrivacity = true;
                                _isHome = true;
                                _isPassword = true;

                                save() async {
                                  saveCred() async {
                                    await signUpWithCred(emailController.text,
                                        passwordController.text);
                                  }

                                  await newUser(
                                          nameController.text,
                                          emailController.text,
                                          phoneController.text,
                                          homeController.text)
                                      .then((_) async {
                                    await saveCred();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LogIn(),
                                      ),
                                    );
                                  });
                                }

                                save();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: const BorderSide(
                                    width: 2.0, color: Colors.black),
                              ),
                              backgroundColor: Colors.grey[200],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.signInAlt,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  lang ? 'Crear cuenta' : 'Create account',
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
                        SizedBox(
                          height: 30,
                          width: 300,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogIn(),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color.fromRGBO(250, 244, 229, 1),
                                  width: 2),
                            ),
                            child: Text(
                              lang
                                  ? '¿Ya tienes cuenta? Inicia sesion aqui!'
                                  : 'Do you already have an account? Log in here!',
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
