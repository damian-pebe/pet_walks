import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/servicios/add_business.dart';
import 'package:petwalks_app/init_app/servicios/edit_business.dart';
import 'package:petwalks_app/init_app/servicios/walk.dart';
import 'package:petwalks_app/init_app/servicios/schedule_walk.dart';
import 'package:petwalks_app/init_app/servicios/request_walk.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/vibrate_container.dart';

class Servicios extends StatefulWidget {
  const Servicios({super.key});

  @override
  State<Servicios> createState() => _ServiciosState();
}

class _ServiciosState extends State<Servicios> {
  bool _visible = true;
  List<String> services = ['request', 'walk', 'business'];

  bool _getIconRequest = false;
  bool _getIconWalk = false;
  bool _getIconBusiness = false;

  void fetchServices() async {
    services = await getServices(email!);
    setState(() {
      _getIconRequest = services.contains('request');
      _getIconWalk = services.contains('walk');
      _getIconBusiness = services.contains('business');
    });
  }

  void _updateServices() async {
    services.clear();
    if (_getIconRequest) {
      services.add('request');
    }
    if (_getIconWalk) {
      services.add('walk');
    }
    if (_getIconBusiness) {
      services.add('business');
    }

    updateServices(email!, services);
  }

  //FETCH EMAIL FROM USER
  String? email;
  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
      fetchServices();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  void Paseo() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.65),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(244, 210, 248, .30),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Center(
                    child: Text(
                      "¿Desea programar \n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\to\n solicitar un paseo?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  OutlinedButton(
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProgramarPaseo(),
                            ),
                          ),
                      style: customOutlinedButtonStyle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Programar paseo',
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
                            Icons.calendar_month,
                            size: 20,
                            color: Colors.black,
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SolicitarPaseo(),
                            ),
                          ),
                      style: customOutlinedButtonStyle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Solicitar paseo',
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
                            FontAwesomeIcons.clock,
                            size: 20,
                            color: Colors.black,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void Empresa() {
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      barrierColor: Colors.white.withOpacity(0.65),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(244, 210, 248, .30),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: Text(
                        "¿Desea agregar o editar una empresa?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  OutlinedButton(
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AgregarEmpresa(),
                            ),
                          ),
                      style: customOutlinedButtonStyle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Agregar empresa',
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
                            Icons.business_center_outlined,
                            size: 22,
                            color: Colors.black,
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  OutlinedButton(
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditaEmpresa(),
                            ),
                          ),
                      style: customOutlinedButtonStyle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Editar empresa',
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
                            FontAwesomeIcons.solidEdit,
                            size: 16,
                            color: Colors.black,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        );
      },
    );
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
              titleW(title: 'Servicios'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            alignment: Alignment.topRight,
                            child: OutlinedButton(
                                onPressed: () async {
                                  if (!_visible) {
                                    _updateServices();
                                  } else {
                                    fetchServices();
                                  }
                                  setState(() {
                                    _visible = !_visible;
                                  });
                                },
                                style: customOutlinedButtonStyle(),
                                child: Icon(
                                  _visible
                                      ? FontAwesomeIcons.slidersH
                                      : FontAwesomeIcons.checkCircle,
                                  size: 30,
                                  color: Colors.black,
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Visibility(
                          visible: _visible,
                          child: Column(
                            children: [
                              Visibility(
                                visible: !_getIconRequest,
                                child: OutlinedButton(
                                    onPressed: () {
                                      Paseo();
                                    },
                                    style: customOutlinedButtonStyle(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.dog,
                                          size: 25,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          'Solicitar paseos',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 25.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Visibility(
                                visible: !_getIconWalk,
                                child: OutlinedButton(
                                    onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Pasear(),
                                          ),
                                        ),
                                    style: customOutlinedButtonStyle(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.walking,
                                          size: 25,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          'Pasear mascotas',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 25.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Visibility(
                                visible: !_getIconBusiness,
                                child: OutlinedButton(
                                    onPressed: () => Empresa(),
                                    style: customOutlinedButtonStyle(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.add_business_rounded,
                                          size: 25,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          'Empresas',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 25.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                            visible: !_visible,
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _getIconRequest = !_getIconRequest;
                                        });
                                      },
                                      style: customOutlinedButtonStyle(),
                                      child: Column(
                                        children: [
                                          Icon(
                                            _getIconRequest
                                                ? Icons
                                                    .check_box_outline_blank_outlined
                                                : Icons.check_box_outlined,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _getIconWalk = !_getIconWalk;
                                        });
                                      },
                                      style: customOutlinedButtonStyle(),
                                      child: Column(
                                        children: [
                                          Icon(
                                            _getIconWalk
                                                ? Icons
                                                    .check_box_outline_blank_outlined
                                                : Icons.check_box_outlined,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _getIconBusiness = !_getIconBusiness;
                                        });
                                      },
                                      style: customOutlinedButtonStyle(),
                                      child: Column(
                                        children: [
                                          Icon(
                                            _getIconBusiness
                                                ? Icons
                                                    .check_box_outline_blank_outlined
                                                : Icons.check_box_outlined,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    VibratingContainer(
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 22.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.dog,
                                                size: 25,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                'Solicitar paseos',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 25.0,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    VibratingContainer(
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 24.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.walking,
                                                size: 25,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 0,
                                              ),
                                              Text(
                                                'Pasear mascotas',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 25.0,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    VibratingContainer(
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 58.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Icon(
                                                Icons.add_business_rounded,
                                                size: 25,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                'Empresas',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 25.0,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Image.asset(
                          'assets/logo.png',
                          width: 230,
                          height: 230,
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ));
  }
}
