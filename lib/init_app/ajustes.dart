import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/ajustes/edit_user.dart';
import 'package:petwalks_app/init_app/ajustes/pets.dart';
import 'package:petwalks_app/pages/opciones/opciones.dart';
import 'package:petwalks_app/services/auth_service.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  final _auth = AuthService();

  bool idioma = true;
  late String lang;

  String? email;
  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {
      print('Error getting email from user');
    }
  }

  void _getLanguaje() async {
    lang = await getLanguaje(email);
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    _getLanguaje();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: Column(
            children: [
              titleW(title: 'Ajustes'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      EmptyBox(w: 0, h: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 24.0),
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
                                  "Idioma ",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey[600],
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
                          OutlinedButton(
                            onPressed: () {
                              if (idioma) {
                                updateLanguaje(email, 'english');
                              } else {
                                updateLanguaje(email, 'spanish');
                              }
                              _getLanguaje();

                              toastF(lang);

                              setState(() {
                                idioma = !idioma;
                                //GETS AND UPDATES right here
                              });
                            },
                            child: SizedBox(
                              height: 30,
                              child: Image.asset(
                                idioma ? 'assets/mexico.png' : 'assets/eu.png',
                                fit: BoxFit.cover,
                                height: 30,
                              ),
                            ),
                            style: customOutlinedButtonStyle(),
                          ),
                        ],
                      ),
                      EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditUser(),
                                ),
                              ),
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Editar perfil',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.account_circle_outlined,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Mascotas(),
                                ),
                              ),
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Administrar mascotas ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                FontAwesomeIcons.dog,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () async {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tutorial de uso',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.video_camera_front_outlined,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () async {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sobre nosotros',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.perm_identity,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      EmptyBox(w: 0, h: 30),
                      OutlinedButton(
                          onPressed: () async {},
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sugerencias',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.send,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          )),
                      EmptyBox(w: 0, h: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.workspace_premium,
                                  size: 35,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
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
                                onPressed: () async {
                                  await _auth.signOut();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Opciones(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.logout_outlined,
                                  size: 35,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Log out',
                                style: TextStyle(
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
