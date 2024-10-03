import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/servicios/add_business.dart';
import 'package:petwalks_app/init_app/servicios/agreement.dart';
import 'package:petwalks_app/init_app/ajustes/business/view_business.dart';
import 'package:petwalks_app/init_app/servicios/walk.dart';
import 'package:petwalks_app/init_app/servicios/schedule_walk.dart';
import 'package:petwalks_app/init_app/servicios/request_walk.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';
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
    if (mounted) {
      setState(() {
        _getIconRequest = services.contains('request');
        _getIconWalk = services.contains('walk');
        _getIconBusiness = services.contains('business');
      });
    }
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
  String? idUser;
  String? agreementStatus;
  Future<void> _fetchUserEmail() async {
    email = await fetchUserEmail();
    fetchServices();
    idUser = await findMatchingUserId(email!);
    agreementStatus = await getAgreementStatus(idUser!);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    if (mounted) {
      setState(() {});
    }
  }

  void DialogAgreement() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.65),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(159, 229, 248, 210),
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
                      lang!
                          ? 'Para asegurar la integridad tanto de los paseadores como de los dueños es necesario llenar la solicitud para unirse al programa, al ser aceptado se le notificara y podra hacer uso de todos los servicios'
                          : 'To ensure the integrity of both walkers and owners, it is necessary to fill out the application to join the program. Once accepted, you will be notified and can avail yourself of all the services.',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  OutlinedButton(
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Agreement(),
                            ),
                          ),
                      style: customOutlinedButtonStyle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            lang! ? 'Ir a contrato' : 'Go to agreement',
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
                            Icons.document_scanner,
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

  void Paseo() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.65),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(159, 229, 248, 210),
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
                        lang!
                            ? '¿Desea programar o solicitar un paseo?'
                            : 'Do you want to scheduleor request a new walk?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
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
                            lang! ? 'Programar paseo' : 'Schedule walk',
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
                            lang! ? 'Solicitar paseo' : 'Request walk',
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
          backgroundColor: Color.fromARGB(159, 229, 248, 210),
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
                        lang!
                            ? '¿Desea agregar o editar una empresa?'
                            : 'Do you want to add or edit a business',
                        style: const TextStyle(
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
                            lang! ? 'Agregar empresa' : 'Add business',
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
                              builder: (context) => const Business(),
                            ),
                          ),
                      style: customOutlinedButtonStyle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            lang! ? 'Editar empresa' : 'Edit business',
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
          body: lang == null
              ? const Center(
                  child: SpinKitSpinningLines(
                      color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
              : Column(
                  children: [
                    titleW(title: lang! ? 'Servicios' : 'Services'),
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
                                height: 10,
                              ),
                              Visibility(
                                visible: _visible,
                                child: Column(
                                  children: [
                                    Visibility(
                                      visible: !_getIconRequest,
                                      child: OutlinedButton(
                                          onPressed: () {
                                            if (agreementStatus ==
                                                'unverified') {
                                              DialogAgreement();
                                            } else if (agreementStatus ==
                                                'inCheck') {
                                              toastF(lang!
                                                  ? 'Espera la respuesta de tu solicitud para entrar al programa'
                                                  : '"Wait for the response to your request about joining to the program"');
                                            } else {
                                              Paseo();
                                            }
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
                                                lang!
                                                    ? 'Solicitar paseos'
                                                    : 'Request walk',
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
                                          onPressed: () {
                                            if (agreementStatus ==
                                                'unverified') {
                                              DialogAgreement();
                                            } else if (agreementStatus ==
                                                'inCheck') {
                                              toastF(lang!
                                                  ? 'Espera la respuesta de tu solicitud para entrar al programa'
                                                  : '"Wait for the response to your request about joining to the program"');
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Pasear(),
                                                ),
                                              );
                                            }
                                          },
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
                                                lang!
                                                    ? 'Pasear mascotas'
                                                    : 'Walk pets',
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
                                          onPressed: () {
                                            if (agreementStatus ==
                                                'unverified') {
                                              DialogAgreement();
                                            } else if (agreementStatus ==
                                                'inCheck') {
                                              toastF(lang!
                                                  ? 'Espera la respuesta de tu solicitud para entrar al programa'
                                                  : '"Wait for the response to your request about joining to the program"');
                                            } else {
                                              Empresa();
                                            }
                                          },
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
                                                lang! ? 'Empresas' : 'Business',
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
                                                _getIconRequest =
                                                    !_getIconRequest;
                                              });
                                            },
                                            style: customOutlinedButtonStyle(),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  _getIconRequest
                                                      ? Icons
                                                          .check_box_outline_blank_outlined
                                                      : Icons
                                                          .check_box_outlined,
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
                                                      : Icons
                                                          .check_box_outlined,
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
                                                _getIconBusiness =
                                                    !_getIconBusiness;
                                              });
                                            },
                                            style: customOutlinedButtonStyle(),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  _getIconBusiness
                                                      ? Icons
                                                          .check_box_outline_blank_outlined
                                                      : Icons
                                                          .check_box_outlined,
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
                                                    vertical: 20.0,
                                                    horizontal: 22.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                      lang!
                                                          ? 'Solicitar paseos'
                                                          : 'Request walk',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 25.0,
                                                        fontStyle:
                                                            FontStyle.italic,
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
                                                    vertical: 20.0,
                                                    horizontal: 24.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                      lang!
                                                          ? 'Pasear mascotas'
                                                          : 'Walk pets',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 25.0,
                                                        fontStyle:
                                                            FontStyle.italic,
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
                                                    vertical: 20.0,
                                                    horizontal: 58.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_business_rounded,
                                                      size: 25,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                      lang!
                                                          ? 'Empresas'
                                                          : 'Business',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 25.0,
                                                        fontStyle:
                                                            FontStyle.italic,
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
