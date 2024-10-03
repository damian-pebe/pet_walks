import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/init_app/ajustes/pets/add_pets.dart';
import 'package:petwalks_app/init_app/ajustes/pets/view_pets.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class Mascotas extends StatefulWidget {
  const Mascotas({super.key});

  @override
  State<Mascotas> createState() => _MascotasState();
}

class _MascotasState extends State<Mascotas> {
  bool isToggled = true;

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
            ? const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
            : Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Stack(
                    children: [
                      titleW(title: lang! ? 'Mascotas' : 'Pets'),
                      Positioned(
                        left: 30,
                        top: 70,
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back_ios,
                                  size: 30, color: Colors.black),
                            ),
                            Text(
                              lang! ? 'Regresar' : 'Back',
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.asset(
                            'assets/logoApp.png',
                            width: 120,
                            height: 120,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isToggled = !isToggled;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              width: 90,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: isToggled
                                    ? Color.fromARGB(100, 169, 200, 149)
                                    : Color.fromARGB(255, 169, 200, 149),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: Duration(milliseconds: 400),
                                    curve: Curves.easeIn,
                                    left: isToggled ? 50 : 0,
                                    right: isToggled ? 0 : 50,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        isToggled
                                            ? Icons.remove_red_eye_rounded
                                            : Icons.add_circle_outline,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: isToggled ? ViewPets() : AddPets(),
                  ),
                ],
              ),
      ),
    );
  }
}
