import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/init_app/ajustes/pets/pet_info.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/home/editHome.dart';
import 'package:petwalks_app/pages/opciones/home/selectHome.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';
import 'package:petwalks_app/widgets/visibility.dart';

class SolicitarPaseo extends StatefulWidget {
  const SolicitarPaseo({super.key});

  @override
  State<SolicitarPaseo> createState() => _SolicitarPaseoState();
}

class _SolicitarPaseoState extends State<SolicitarPaseo> {
  bool mascotas = true;
  bool domicilio = true;
  bool _isLoading = false;
  TextEditingController timeShowController = TextEditingController(text: "1");
  TextEditingController homeController = TextEditingController(text: "");
  String payMethod = 'Efectivo';
  String walkWFriends = 'Si';
  String timeWalking = '15';
  List<String> selectedPets = [];
  TextEditingController descriptionController = TextEditingController(text: "");
  late LatLng homelatlng;

  Map<String, dynamic> showData = {};
  Map<String, dynamic> infoPet = {};
  late List<String> list = [];
  Map<String, bool> checkboxStates = {};

  String? email;
  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {
      print('Error getting email from user');
    }
    _fetchBuilderInfo();
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
                  const Text(
                    "Seleccionar Mascotas",
                    style: TextStyle(
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
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No pets found'));
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
                                          print('Selected Pets: $selectedPets');
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
                      toastF(selectedPets.toString());
                      Navigator.pop(context);
                    },
                    style: customOutlinedButtonStyle(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.checklist_rtl_sharp,
                          size: 28,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Aceptar',
                          style: TextStyle(
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
        scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    const titleW(title: 'Solicitar'),
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
                              'Regresar',
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Text(
                        'Tiempo de \npaseo (min): ',
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
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          timeWalking = '15';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: timeWalking == '15'
                              ? Colors.black
                              : Color.fromRGBO(250, 244, 229, .65),
                          width: 2,
                        ),
                      ),
                      child: Text('15',
                          style: TextStyle(
                            color: timeWalking == '15'
                                ? Colors.black
                                : Colors.black,
                          )),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          timeWalking = '30';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: timeWalking == '30'
                              ? Colors.black
                              : Color.fromRGBO(250, 244, 229, .65),
                          width: 2,
                        ),
                      ),
                      child: Text('30',
                          style: TextStyle(
                            color: timeWalking == '30'
                                ? Colors.black
                                : Colors.black,
                          )),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          timeWalking = '45';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: timeWalking == '45'
                              ? Colors.black
                              : Color.fromRGBO(250, 244, 229, .65),
                          width: 2,
                        ),
                      ),
                      child: Text('45',
                          style: TextStyle(
                            color: timeWalking == '45'
                                ? Colors.black
                                : Colors.black,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Text(
                        '¿Paseo con \nmas mascotas?: ',
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
                              : Color.fromRGBO(250, 244, 229, .65),
                          width: 2,
                        ),
                      ),
                      child: Text('Si',
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
                              : Color.fromRGBO(250, 244, 229, .65),
                          width: 2,
                        ),
                      ),
                      child: Text('No',
                          style: TextStyle(
                            color: walkWFriends == 'No'
                                ? Colors.black
                                : Colors.black,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: 250,
                  child: TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      keyboardType: TextInputType.multiline,
                      decoration: StyleTextField('Descripcion')),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => details(),
                  style: OutlinedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(width: 2.0, color: Colors.black),
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Seleccionar mascotas',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 22.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.list,
                        size: 25,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                VisibilityW(
                    boolean: mascotas, string: 'Falta seleccionar mascota/s'),
                const SizedBox(height: 10),
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
                            homelatlng = result['position'];
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
                            const Icon(
                              Icons.edit,
                              size: 25,
                              color: Colors.black,
                            ),
                          ],
                        )),
                  ],
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
                    "Domicilio: ${homeController.text}",
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
                    boolean: domicilio, string: 'Falta seleccionar domicilio'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Text(
                        'Metodo de pago: ',
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
                              : Color.fromRGBO(250, 244, 229, .65),
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
                              : Color.fromRGBO(250, 244, 229, .65),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
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
                          'Mostrar solicitud por: ${timeShowController.text} hrs\n(Max: 8 horas)',
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
                              if (!['1', '2', '3', '4', '5', '6', '7', '8']
                                  .contains(x)) {
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
                            decoration: StyleTextField('Tiempo'))),
                  ],
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
                            setState(() {});

                            return mascotas && domicilio;
                          }

                          DateTime date = DateTime.now();
                          saveTime() {
                            date = date.add(Duration(
                                hours: int.tryParse(timeShowController.text) ??
                                    0));
                            print(date);
                          }

                          save() async {
                            String lastWalkId = await newWalk(
                                date,
                                timeShowController.text,
                                payMethod,
                                walkWFriends,
                                timeWalking,
                                homeController.text,
                                homelatlng,
                                descriptionController.text,
                                selectedPets,
                                'walk',
                                email!);
                            await addWalkToUser(email!, lastWalkId);
                          }

                          if (pass()) {
                            setState(() {
                              _isLoading = true;
                            });
                            saveTime();

                            await save();

                            setState(() {
                              _isLoading = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Funcion(),
                              ),
                            );
                          }
                        },
                  style: customOutlinedButtonStyle(),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.dog,
                              size: 25,
                              color: Colors.black,
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Solicitar paseo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 22.0,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(width: 15),
                            Icon(
                              FontAwesomeIcons.bone,
                              size: 25,
                              color: Colors.black,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
