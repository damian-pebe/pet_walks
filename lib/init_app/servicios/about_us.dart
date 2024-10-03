import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/services/firebase_services.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
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
    return Scaffold(
        body: lang == null
            ? const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
            : Stack(children: [
                Column(
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: 0.4,
                        child: Image.asset(
                          'assets/about_us/image1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Opacity(
                        opacity: 0.4,
                        child: Image.asset(
                          'assets/about_us/image2.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Opacity(
                        opacity: 0.4,
                        child: Image.asset(
                          'assets/about_us/image3.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          lang! ? 'SOBRE NOSOTROS' : 'ABOUT US',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                offset: Offset(3.0, 3.0),
                                blurRadius: 10.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          lang!
                              ? 'PetWalks nació para resolver la falta de tiempo que tienen muchos dueños para pasear a sus mascotas. Entendemos que la vida diaria puede ser agitada, y por eso conectamos a dueños de mascotas con paseadores de confianza. Nuestra aplicación facilita la solicitud de paseos de manera rápida y segura.\n\nOfrecemos:\n - Conexión sencilla entre dueños y paseadores\n - Geolocalización y seguimiento en tiempo real\n - Oportunidades de empleo flexible para paseadores\n\nNuestro compromiso es la seguridad y el bienestar de las mascotas, brindando tranquilidad tanto a los dueños como a los paseadores a través de notificaciones y reportes en caso de incidentes.'
                              : 'PetWalks was created to solve the issue of lack of time many pet owners face to walk their pets. We understand daily life can be hectic, so we connect pet owners with trusted walkers. Our app makes it quick and safe to request pet walks.\n\nWe offer:\n - Easy connection between owners and walkers\n - Geolocation and real-time tracking\n - Flexible employment opportunities for walkers\n\nOur commitment is to the safety and well-being of pets, providing peace of mind for both owners and walkers through notifications and incident reports.',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                offset: Offset(3.0, 3.0),
                                blurRadius: 10.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.black,
                                ),
                                Text(lang! ? '   Regresar   ' : '   Back   ',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ))
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
              ]));
  }
}
