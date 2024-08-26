import 'package:flutter/material.dart';
import 'package:petwalks_app/init_app/ajustes/pets/add_pets.dart';
import 'package:petwalks_app/init_app/ajustes/pets/view_pets.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class Mascotas extends StatefulWidget {
  const Mascotas({super.key});

  @override
  State<Mascotas> createState() => _MascotasState();
}

class _MascotasState extends State<Mascotas> {
  bool isToggled = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1)),
      home: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            titleW(title: 'Mascotas'),
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
