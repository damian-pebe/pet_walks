import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/ajustes/edit_user.dart';
import 'package:petwalks_app/init_app/ajustes/pets.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/options.dart';
import 'package:petwalks_app/services/auth_service.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/services/wrapper.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: lang == null
              ? null
              : Column(
                  children: [
                    titleW(title: lang! ? 'Configuracion' : 'Configuration'),
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
                                    color: Colors.yellow[100],
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        lang! ? 'Idioma' : 'Language',
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
                                  onPressed: () {
                                    updateLanguage(!lang!);
                                    _getLanguage();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Wrapper(),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 40,
                                    child: lang == null
                                        ? CircularProgressIndicator()
                                        : Image.asset(
                                            lang!
                                                ? 'assets/mexico.png'
                                                : 'assets/eu.png',
                                            fit: BoxFit.cover,
                                            height: 30,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            const EmptyBox(w: 0, h: 30),
                            OutlinedButton(
                                onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const EditUser(),
                                      ),
                                    ),
                                style: customOutlinedButtonStyleYellow(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang! ? 'Editar perfil' : 'Language',
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
                                onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Mascotas(),
                                      ),
                                    ),
                                style: customOutlinedButtonStyleYellow(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang!
                                          ? 'Administrar mascotas'
                                          : 'Manage pets',
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
                                style: customOutlinedButtonStyleYellow(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang!
                                          ? 'Tutorial de uso'
                                          : 'Usage tutorial',
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
                                style: customOutlinedButtonStyleYellow(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang! ? 'Sobre nosotros' : 'About us',
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
                                style: customOutlinedButtonStyleYellow(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang! ? 'Sugerencias' : 'Suggestions',
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
                                      onPressed: () async {
                                        await _auth.signOut();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Opciones(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.logout_outlined,
                                        size: 35,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      lang! ? 'Salir' : 'Log out',
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
