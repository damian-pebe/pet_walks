// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/home/editHome.dart';
import 'package:petwalks_app/pages/opciones/home/selectHome.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';
import 'package:petwalks_app/widgets/visibility.dart';

class AgregarEmpresa extends StatefulWidget {
  const AgregarEmpresa({super.key});

  @override
  State<AgregarEmpresa> createState() => _AgregarEmpresaState();
}

class _AgregarEmpresaState extends State<AgregarEmpresa> {
  late String email;
  _email() async {
    email = await fetchUserEmail();
  }

  @override
  void initState() {
    super.initState();
    _email();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();

    setState(() {});
  }

  bool _isLoading = false;
  TextEditingController nameController = TextEditingController(text: "");
  final TextEditingController _categoryController =
      TextEditingController(text: "");
  String? categoryController;
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController homeController = TextEditingController(text: "");
  TextEditingController descriptionController = TextEditingController(text: "");

  TextEditingController tokenController = TextEditingController(text: "");
  //token phone verification == 4 digits
  String inTokenPhone = '1234';
  String tokenSent = '';
  bool verificationModule = false;

  List<File> _imageFiles = [];
  List<String> _downloadUrls = [];

  Future<void> _pickImages() async {
    setState(() {
      _downloadUrls = [];
      _imageFiles = [];
    });
    final pickedFiles = await ImagePicker().pickMultiImage(imageQuality: 80);

    setState(() {
      _imageFiles =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
    await _uploadImages();
  }

  Future<void> _uploadImages() async {
    if (_imageFiles.isEmpty) return;

    for (var imageFile in _imageFiles) {
      final fileName = path.basename(imageFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/BusinessImages/$fileName');
      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _downloadUrls.add(url);
      });
    }
    setState(() {});
  }

  late LatLng homelatlng;

  List<String> category = [
    'Veterinaria/Veterinary',
    'Escuela/School',
    'Guardería/Daycare',
    'Hotel/Hotel',
    'Refugio/Shelter',
    'Mascotienda/Pet store',
    'Tienda comida/Pet food store',
    'Otros/Others'
  ];

  bool isVerified = false;
  IconData getIcon() {
    setState(() {});
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
                lang!
                    ? 'Verificar su numero de telefono'
                    : 'Verify phone number',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              const Icon(
                Icons.send,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(159, 229, 248, 210),
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
                    decoration: StyleTextField(
                      lang! ? 'Telefono' : 'Phone number',
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () {
                      if (sameToken(tokenController.text)) {
                        verificationModule = true;
                        toastF(
                          lang!
                              ? 'Telefono verificado con exito'
                              : 'Phone verification successfully ',
                        );
                      } else {
                        toastF(
                          lang!
                              ? 'El token enviado no coincide'
                              : 'Token doesnt match ',
                        );
                      }
                      Navigator.pop(context, verificationModule);
                    },
                    style: customOutlinedButtonStyle(),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Colors.black,
                        ),
                        Text(
                          lang! ? 'Verificar' : 'Verify',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: !_isSame,
              child: Text(
                lang! ? 'El token enviado no coincide' : 'Token doesnt match ',
                style: const TextStyle(color: Colors.red, fontSize: 10),
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
                lang! ? 'Enviar token de verificacion' : 'Send verify token ',
                style: const TextStyle(
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
                lang! ? 'Salir' : 'Back',
                style: const TextStyle(fontSize: 13, color: Colors.black),
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

  bool verifyFieldsHome() {
    if (homeController.text == "") return false;
    return true;
  }

  bool verifyFields() {
    if (!verifyFieldsName()) return false;
    if (!isVerified) return false;
    if (!verifyFieldsHome()) return false;

    return true;
  }

  bool _isName = true;
  bool _isVerified = false;
  bool _isHome = false;
  final _isSame = false;

  @override
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(children: [
                        Stack(
                          children: [
                            titleW(
                              title: lang! ? 'Agregar empresa' : 'Add business',
                            ),
                            Positioned(
                                left: 10,
                                top: 70,
                                child: Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.arrow_back_ios,
                                          size: 30, color: Colors.black),
                                    ),
                                    Text(
                                      lang! ? 'Regresar' : 'Back',
                                      style: const TextStyle(fontSize: 10),
                                    )
                                  ],
                                )),
                          ],
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            TextField(
                              keyboardType: TextInputType.name,
                              controller: nameController,
                              decoration: StyleTextField(
                                lang! ? 'Nombre' : 'Name',
                              ),
                            ),
                            VisibilityW(
                              boolean: _isName,
                              string: lang!
                                  ? 'Falta nombre de la empresa'
                                  : ' Missing business name ',
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              child: _downloadUrls.isNotEmpty
                                  ? PhotoCarousel(
                                      imageUrls:
                                          (_downloadUrls as List<dynamic>)
                                              .map((item) => item.toString())
                                              .toList(),
                                    )
                                  : Text(
                                      lang!
                                          ? 'Click para seleccionar imagenes'
                                          : 'Click to select images',
                                      style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 20,
                                          color: Colors.black),
                                    ),
                              onTap: () => _pickImages(),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(
                              height: 10,
                            ),
                            DropdownButton<String>(
                              value: categoryController,
                              isDense: true,
                              dropdownColor: Colors.grey[200],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              onChanged: (newValue) {
                                setState(() {
                                  categoryController = newValue;
                                  _categoryController.text = newValue ?? '';
                                });
                              },
                              items: category.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: TextField(
                                    enabled: enablePhone,
                                    keyboardType: TextInputType.number,
                                    controller: phoneController,
                                    decoration: StyleTextField(
                                      lang! ? 'Telefono' : 'Phone number',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 110,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      verifyPhone(phoneController.text);

                                      if (verificationModule) {
                                        isVerified = true;
                                        setState(() {});
                                      }
                                    },
                                    style: customOutlinedButtonStyle(),
                                    child: Column(
                                      children: [
                                        Icon(
                                          getIcon(),
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          lang!
                                              ? 'Verificacion'
                                              : 'Verification',
                                          style: const TextStyle(
                                              fontSize: 8, color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            VisibilityW(
                              boolean: !_isVerified,
                              string: lang!
                                  ? 'Falta verificar telefono del usuario'
                                  : 'Missing phone number verification',
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
                                          lang! ? 'Seleccionar' : 'Select ',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 18.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    )),
                                const SizedBox(
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
                                        homeController.text =
                                            domicilio.toString();
                                      });
                                    },
                                    style: customOutlinedButtonStyle(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(
                              height: 5,
                            ),
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
                              boolean: !_isHome,
                              string: lang!
                                  ? 'Falta seleccionar domicilio'
                                  : 'Missing address',
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: TextField(
                                      controller: descriptionController,
                                      maxLines: 4,
                                      keyboardType: TextInputType.multiline,
                                      decoration: StyleTextField(lang!
                                          ? 'Descripcion'
                                          : 'Description')),
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (!verifyFields()) {
                                        if (!verifyFieldsName()) {
                                          setState(() {
                                            _isName = false;
                                          });
                                        } else {
                                          setState(() {
                                            _isName = true;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          _isName = true;
                                          _isLoading = true;
                                        });

                                        Future<void> uploadImages() async {
                                          await _uploadImages();
                                        }

                                        Future<void> save() async {
                                          String lastBusinessId =
                                              await newBusiness(
                                            nameController.text,
                                            categoryController,
                                            phoneController.text,
                                            homeController.text,
                                            homelatlng,
                                            descriptionController.text,
                                            _downloadUrls,
                                          );
                                          await addBusinessToUser(
                                              email, lastBusinessId);
                                        }

                                        await uploadImages();
                                        await save();

                                        setState(() {
                                          _isLoading = false;
                                        });

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Funcion(),
                                          ),
                                        );
                                      }
                                    },
                              style: customOutlinedButtonStyle(),
                              child: _isLoading
                                  ? const SpinKitSpinningLines(
                                      color: Color.fromRGBO(169, 200, 149, 1),
                                      size: 50.0)
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_business_sharp,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Text(
                                          lang!
                                              ? 'Agregar empresa'
                                              : 'Add business',
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                      ],
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
