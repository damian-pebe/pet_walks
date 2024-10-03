// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/init_app/ajustes/pets/pet_info.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/home/editHome.dart';
import 'package:petwalks_app/pages/opciones/home/selectHome.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/date_time.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';
import 'package:petwalks_app/widgets/visibility.dart';

class TravelTo extends StatefulWidget {
  final LatLng geoPoint;
  final String address;
  const TravelTo({required this.address, required this.geoPoint, super.key});

  @override
  State<TravelTo> createState() => _TravelToState();
}

class _TravelToState extends State<TravelTo> {
  TextEditingController timeShowController = TextEditingController(text: "1");
  TextEditingController homeController = TextEditingController(text: "");
  String payMethod = 'Efectivo';
  String walkWFriends = 'Si';
  List<String> selectedPets = [];
  TextEditingController descriptionController = TextEditingController(text: "");
  LatLng? homelatlng;

  Map<String, dynamic> showData = {};
  Map<String, dynamic> infoPet = {};
  late List<String> list = [];
  Map<String, bool> checkboxStates = {};

  bool mascotas = true;
  bool domicilio = true;
  bool fechas = true;
  bool horario = true;
  bool _isLoading = false;

  DateTime? endDate;
  DateTime? startDate;
  List<DateTime>? selectedDates;

  String mode = '';
  TimeOfDay? _selectedTime;
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String? email;
  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {}
    _fetchBuilderInfo();
    statusPremiumInstance();
  }

  void _fetchBuilderInfo() async {
    list = await getPets(email!);
    showData = await fetchBuilderInfo(list);
    setState(() {});

    List<String> petIds = await getPets(email!);
    setState(() {
      for (var id in petIds) {
        checkboxStates[id] = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    _getLanguage();
    ();
  }

  bool? premium;
  void statusPremiumInstance() async {
    premium = await getPremiumStatus(email!);
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  void details() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(250, 244, 229, 1).withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EmptyBox(h: 40),
                  Text(
                    lang! ? 'Seleccionar Mascotas' : 'Select pets',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FutureBuilder<List<String>>(
                      future: getPets(email!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: SpinKitSpinningLines(
                                  color: Color.fromRGBO(169, 200, 149, 1),
                                  size: 50.0));
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(lang!
                                  ? 'No se encontraron mascotas'
                                  : 'No pets found'));
                        } else {
                          List<String> ids = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: ids.length,
                            itemBuilder: (context, index) {
                              var id = ids[index];
                              var petInfo = showData[id] ?? {};

                              checkboxStates[id] = checkboxStates[id] ?? false;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const EmptyBox(w: 10),
                                      Checkbox(
                                        value: checkboxStates[id],
                                        onChanged: (bool? value) {
                                          setModalState(() {
                                            checkboxStates[id] = value ?? false;
                                            if (checkboxStates[id]!) {
                                              selectedPets.add(id);
                                            } else {
                                              selectedPets.remove(id);
                                            }
                                          });
                                        },
                                      ),
                                      const EmptyBox(w: 10),
                                      const VerticalDivider(
                                        width: 1,
                                        thickness: 1,
                                        color: Colors.black,
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                petInfo['imageUrl'] != null
                                                    ? NetworkImage(
                                                        petInfo['imageUrl'])
                                                    : null,
                                          ),
                                          const EmptyBox(w: 10),
                                          Text(petInfo['name'] ?? 'No name'),
                                        ],
                                      ),
                                      const EmptyBox(w: 20),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            ListTile(
                                              trailing: GestureDetector(
                                                  child: const Icon(
                                                      Icons.chevron_right)),
                                              onTap: () async {
                                                infoPet = await getInfoPets(
                                                    email!, id);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          InfoPet(
                                                              petData: infoPet,
                                                              imageUrls: petInfo[
                                                                  'imageUrls'],
                                                              id: id)),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Colors.black.withOpacity(0.5),
                    thickness: 2,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: customOutlinedButtonStyle(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.checklist_rtl_sharp,
                          size: 28,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          lang! ? 'Aceptar' : 'Accept',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      ),
      home: Scaffold(
        body: lang == null
            ? const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(children: [
                      titleW(
                        title: lang! ? 'Viaje' : 'Travel',
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
                                lang! ? 'Regresar' : 'Back',
                                style: const TextStyle(fontSize: 10),
                              )
                            ],
                          )),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  OutlinedButton(
                                    onPressed: () async {
                                      var result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SelectableCalendar(),
                                          ));
                                      if (result != null) {
                                        if (result.containsKey('dates')) {
                                          selectedDates = result['dates'];
                                          mode = 'selectedDates';
                                        } else if (result
                                                .containsKey('start') &&
                                            result.containsKey('end')) {
                                          startDate = result['start'];
                                          endDate = result['end'];
                                          mode = 'startEnd';
                                        }
                                      } else {}
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0, horizontal: 20.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        side: const BorderSide(
                                            width: 2.0, color: Colors.black),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.calendarCheck,
                                          size: 25,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Fecha/s',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  VisibilityW(
                                    boolean: fechas,
                                    string: lang!
                                        ? 'Falta seleccionar fecha/s'
                                        : 'Dates expected be selected',
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 60,
                              ),
                              Column(
                                children: [
                                  OutlinedButton(
                                    onPressed: () async {
                                      if (mode != '') {
                                        _selectTime();
                                      } else {
                                        toastF(
                                          lang!
                                              ? 'Primero seleccione la/s fechas'
                                              : 'First, select the dates',
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0, horizontal: 20.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        side: const BorderSide(
                                            width: 2.0, color: Colors.black),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.more_time_rounded,
                                          size: 28,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    lang! ? 'Horario' : 'Schedule',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  VisibilityW(
                                    boolean: horario,
                                    string: lang!
                                        ? 'Falta seleccionar horario'
                                        : 'Expected to select the hour',
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 24.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(
                                        color: Colors.grey, width: 2.0),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Text(
                                    lang!
                                        ? '¿Paseo con \nmas mascotas?: '
                                        : 'Walk with other pets',
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
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          walkWFriends = 'Si';
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: walkWFriends == 'Si'
                                              ? Colors.black
                                              : const Color.fromRGBO(
                                                  250, 244, 229, .65),
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(lang! ? 'SI' : 'YES',
                                          style: TextStyle(
                                            color: walkWFriends == 'Si'
                                                ? Colors.black
                                                : Colors.black,
                                          )),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          walkWFriends = 'No';
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: walkWFriends == 'No'
                                              ? Colors.black
                                              : const Color.fromRGBO(
                                                  250, 244, 229, .65),
                                          width: 2,
                                        ),
                                      ),
                                      child: Text('NO',
                                          style: TextStyle(
                                            color: walkWFriends == 'No'
                                                ? Colors.black
                                                : Colors.black,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton(
                                    //seleccionar domicilio
                                    onPressed: () async {
                                      String domicilio = '';
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SelectHome(),
                                        ),
                                      );

                                      if (result != null) {
                                        domicilio = result['domicilio'];
                                        homelatlng = result['position'];
                                      }
                                      setState(() {
                                        homeController.text =
                                            domicilio.toString();
                                      });
                                    },
                                    style: customOutlinedButtonStyle(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
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
                                          lang! ? 'Seleccionar' : 'Select ',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 18.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    )),
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
                                      }
                                      setState(() {
                                        homeController.text =
                                            domicilio.toString();
                                      });
                                    },
                                    style: customOutlinedButtonStyle(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          lang! ? 'Editar' : 'Edit',
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
                          ),
                          const SizedBox(height: 10),
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
                              lang!
                                  ? 'Domicilio: ${homeController.text}'
                                  : 'Address: ${homeController.text}',
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
                          VisibilityW(
                            boolean: domicilio,
                            string: lang!
                                ? 'Falta seleccionar domicilio'
                                : 'Missing address',
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 24.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(
                                        color: Colors.grey, width: 2.0),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.monetization_on_outlined,
                                          color: Colors.black),
                                      Text(
                                        lang!
                                            ? 'Metodo de pago'
                                            : 'Payment method',
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
                                      const Icon(Icons.credit_score_outlined,
                                          color: Colors.black),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          payMethod = 'Efectivo';
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: payMethod == 'Efectivo'
                                              ? Colors.black
                                              : const Color.fromRGBO(
                                                  250, 244, 229, .65),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(Icons.attach_money_outlined,
                                          color: payMethod == 'Efectivo'
                                              ? Colors.black
                                              : Colors.black),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          payMethod = 'Tarjeta';
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: payMethod == 'Tarjeta'
                                              ? Colors.black
                                              : const Color.fromRGBO(
                                                  250, 244, 229, .65),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(Icons.credit_card_sharp,
                                          color: payMethod == 'Tarjeta'
                                              ? Colors.black
                                              : Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                      horizontal: 24.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Text(
                                      lang!
                                          ? 'Tiempo mostrando solicitud'
                                          : 'Time showing request',
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
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                    flex: 1,
                                    child: TextField(
                                        onChanged: (_) {
                                          setState(() {});
                                        },
                                        onEditingComplete: () {
                                          String x = timeShowController.text;
                                          if (![
                                            '1',
                                            '2',
                                            '3',
                                            '4',
                                            '5',
                                            '6',
                                            '7',
                                            '8'
                                          ].contains(x)) {
                                            setState(() {
                                              timeShowController.text = '8';
                                            });
                                          } else if (x == '0' || x == '') {
                                            setState(() {
                                              timeShowController.text = '1';
                                            });
                                          } else {
                                            setState(() {
                                              timeShowController.text = '1';
                                            });
                                          }
                                        },
                                        keyboardType: TextInputType.number,
                                        controller: timeShowController,
                                        decoration: StyleTextField(
                                          lang! ? 'Tiempo' : 'Time',
                                        ))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: OutlinedButton(
                              onPressed: () => details(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: const BorderSide(
                                      width: 2.0, color: Colors.black),
                                ),
                                backgroundColor: Colors.grey[200],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lang!
                                        ? 'Seleccionar mascotas'
                                        : 'Select pets',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(
                                    Icons.list,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          VisibilityW(
                            boolean: mascotas,
                            string: lang!
                                ? 'Falta seleccionar mascota/s'
                                : 'Expected to select pets',
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextField(
                                  controller: descriptionController,
                                  maxLines: 2,
                                  keyboardType: TextInputType.multiline,
                                  decoration: StyleTextField(
                                      lang! ? 'Descripcion' : 'Description')),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    bool pass() {
                                      if (selectedPets.isEmpty) {
                                        mascotas = false;
                                      } else {
                                        mascotas = true;
                                      }
                                      if (homeController.text.isEmpty) {
                                        domicilio = false;
                                      } else {
                                        domicilio = true;
                                      }
                                      if (mode == '') {
                                        fechas = false;
                                      } else {
                                        fechas = true;
                                      }
                                      if (_selectedTime == null) {
                                        horario = false;
                                      } else {
                                        horario = true;
                                      }
                                      setState(() {});

                                      return mascotas &&
                                          domicilio &&
                                          fechas &&
                                          horario;
                                    }

                                    save(DateTime dateElement) async {
                                      //by doing this, im splitting the walks on more walks, doesnt necesary needs to save the array as before
                                      String lastWalkId = await newWalk(
                                        dateElement,
                                        timeShowController.text,
                                        payMethod,
                                        walkWFriends,
                                        null,
                                        homeController.text,
                                        homelatlng!,
                                        descriptionController.text,
                                        selectedPets,
                                        email!,
                                        premium!,

                                        widget
                                            .address, //address from the place to go
                                        widget.geoPoint, //travel to this place
                                      );
                                      await addWalkToUser(email!, lastWalkId);
                                    }

                                    updateTimes() async {
                                      if (mode == 'startEnd') {
                                        startDate = DateTime(
                                          startDate!.year,
                                          startDate!.month,
                                          startDate!.day,
                                          _selectedTime!.hour,
                                          _selectedTime!.minute,
                                        );
                                        endDate = DateTime(
                                          endDate!.year,
                                          endDate!.month,
                                          endDate!.day,
                                          _selectedTime!.hour,
                                          _selectedTime!.minute,
                                        );
                                        for (DateTime dateCount = startDate!;
                                            dateCount.isBefore(endDate!) ||
                                                dateCount
                                                    .isAtSameMomentAs(endDate!);
                                            dateCount = dateCount
                                                .add(const Duration(days: 1))) {
                                          await save(dateCount);
                                        }
                                      } else {
                                        // mode == selectedDates
                                        for (var element in selectedDates!) {
                                          element = DateTime(
                                            element.year,
                                            element.month,
                                            element.day,
                                            _selectedTime!.hour,
                                            _selectedTime!.minute,
                                          );

                                          await save(element);
                                        }
                                      }
                                    }
                                    // save() async {
                                    //   String lastWalkId = await newProgramWalk(
                                    //       date,
                                    //       timeShowController.text,
                                    //       payMethod,
                                    //       walkWFriends,
                                    //       '',
                                    //       widget
                                    //           .address, //address from the place to go
                                    //       widget.geoPoint, //travel to this place
                                    //       homeController.text,
                                    //       homelatlng,
                                    //       descriptionController.text,
                                    //       selectedPets,
                                    //       selectedDates,
                                    //       startDate,
                                    //       endDate,
                                    //       mode,
                                    //       'travel',
                                    //       email!,
                                    //       premium!);
                                    //   await addWalkToUser(email!, lastWalkId);
                                    // }

                                    if (pass()) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      updateTimes();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Funcion(),
                                        ),
                                      );
                                    } else {
                                      toastF(
                                        lang!
                                            ? 'Falta llenar informacion del paseo'
                                            : 'First, complete the empty information',
                                      );
                                    }

                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                            style: customOutlinedButtonStyle(),
                            child: _isLoading
                                ? const SpinKitSpinningLines(
                                    color: Color.fromRGBO(169, 200, 149, 1),
                                    size: 50.0)
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.dog,
                                        size: 25,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        lang!
                                            ? 'Solicitar viaje'
                                            : 'Request travel',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 22.0,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      const Icon(
                                        FontAwesomeIcons.bone,
                                        size: 25,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 23),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
