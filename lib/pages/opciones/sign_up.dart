import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/home/editHome.dart';
import 'package:petwalks_app/pages/opciones/home/selectHome.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/pages/opciones/login.dart';
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
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController homeController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController verifyPasswordController =
      TextEditingController(text: "");

  TextEditingController tokenController = TextEditingController(text: "");
  //token phone verification == 4 digits
  String inTokenPhone = '1234';
  String tokenSent = '';
  bool verificationModule = false;

  String homelatlng = '';

  final _auth = FirebaseAuth.instance;

  bool _obscureText = true;
  bool _obscureText1 = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleVisibility1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  Future<User?> signUpWithCred(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      print(e.toString());
    }
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
                "Verificar su numero de telefono",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Icon(
                Icons.send,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
          backgroundColor: Color.fromRGBO(250, 244, 229, 1),
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
                      decoration: StyleTextField('Telefono')),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () {
                      if (sameToken(tokenController.text)) {
                        verificationModule = true;
                        toastF("Telefono verificado con exito");
                      } else {
                        toastF("* El token enviado no coincide");
                      }
                      Navigator.pop(context, verificationModule);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(width: 2.0, color: Colors.black),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: Colors.black,
                        ),
                        Text(
                          "Verificar",
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Visibility(
              visible: !_isSame,
              child: Text(
                "* El token enviado no coincide",
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                //enviar token
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color.fromRGBO(250, 244, 229, .65), width: 2),
              ),
              child: Text(
                'Enviar token de verificacion',
                style: TextStyle(
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
                'Salir',
                style: TextStyle(fontSize: 13, color: Colors.black),
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
    if (inTokenPhone != sent) return false;

    return true;
  }

  bool verifyFieldsName() {
    if (nameController.text == "") return false;
    return true;
  }

  bool verifyFieldsEmail() {
    if (emailController.text == "") return false;
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

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // Signed in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Funcion()),
        );
      }
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
                    const titleW(title: 'Registrarme'),
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
                              'Regresar',
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
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                          keyboardType: TextInputType.name,
                          controller: nameController,
                          decoration: StyleTextField('Nombre')),
                      VisibilityW(
                        boolean: !_isName,
                        string: 'Falta nombre del usuario',
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
                          "* Falta email del usuario",
                          style: TextStyle(color: Colors.red, fontSize: 10),
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
                                decoration: StyleTextField('Telefono')),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 90,
                            child: OutlinedButton(
                              onPressed: () {
                                if (isVerified) {
                                  toastF('Numero ya verificacdo');
                                  return;
                                }

                                verifyPhone(phoneController.text);

                                if (verificationModule) {
                                  isVerified = true;
                                  setState(() {});
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 0.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
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
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    'Verificacion',
                                    style: TextStyle(
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
                          "* Falta verificar telefono del usuario",
                          style: TextStyle(color: Colors.red, fontSize: 10),
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
                                    builder: (context) => SelectHome(),
                                  ),
                                );

                                if (result != null) {
                                  domicilio = result['domicilio'];
                                  print('\nDOMICILIO: ' + domicilio);
                                }
                                setState(() {
                                  homeController.text = domicilio.toString();
                                });
                              },
                              style: customOutlinedButtonStyle(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.home,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Seleccionar\ndomicilio',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          OutlinedButton(
                              //editar domicilio
                              onPressed: () async {
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
                                  print('\nDOMICILIO: ' + domicilio);
                                }
                                setState(() {
                                  homeController.text = domicilio.toString();
                                });
                              },
                              style: customOutlinedButtonStyle(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Editar\ndomicilio',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ],
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                        visible: !_isHome,
                        child: Text(
                          "* Falta seleccionar domicilio del usuario",
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
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
                          "Domicilio: " + homeController.text,
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
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextField(
                          obscureText: _obscureText,
                          controller: passwordController,
                          decoration: StyleTextField('Contraseña')),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                          obscureText: _obscureText1,
                          controller: verifyPasswordController,
                          decoration: StyleTextField('Confirmar contraseña')),
                      Visibility(
                        visible: !_isPassword,
                        child: Text(
                          "* Las contraseñas ingresadas no son validas o no coinciden",
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        child: Row(
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
                                          'Terminos y condiciones y politicas de privacidad',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: Text(
                                          'Terminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidadTerminos y condiciones y politicas de privacidad',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Color.fromRGBO(250, 244, 229, 1),
                                      width: 2),
                                ),
                                child: Text(
                                  'Acepto los terminos y condiciones de uso asi como las politicas de privacidad',
                                  style: TextStyle(
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
                                    toastF('Ya fueron aceptados');
                                    return;
                                  }

                                  setState(() {
                                    isPrivacity = !isPrivacity;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
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
                      ),
                      Visibility(
                        visible: !_isPrivacity,
                        child: Text(
                          "* Necesita aceptar los terminos y condiciones de uso asi como las politicas de privacidad",
                          style: TextStyle(color: Colors.red, fontSize: 10),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.signInAlt,
                                size: 30,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                'Crear cuenta',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20),
                              ),
                            ],
                          )),
                      SizedBox(
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
                            side: BorderSide(
                                color: Color.fromRGBO(250, 244, 229, 1),
                                width: 2),
                          ),
                          child: Text(
                            '¿Ya tienes cuenta? Inicia sesion aqui!',
                            style: TextStyle(
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
        ));
  }
}
