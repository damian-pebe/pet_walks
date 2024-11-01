// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/pages/opciones/home/editHome.dart';
import 'package:petwalks_app/pages/opciones/home/selectHome.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/services/twilio.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class EditInfoBusiness extends StatefulWidget {
  final Map<String, dynamic> businessData;
  final String id;
  const EditInfoBusiness(
      {required this.businessData, required this.id, super.key});

  @override
  State<EditInfoBusiness> createState() => _EditInfoBusiness();
}

class _EditInfoBusiness extends State<EditInfoBusiness> {
  bool _isLoading = false;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController homeController;
  late TextEditingController descriptionController;
  late String selectedCategory;
  final TextEditingController tokenController = TextEditingController();

  List<File> _imageFiles = [];
  // ignore: prefer_final_fields
  List<String> _downloadUrls = [];

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
  Future<void> _pickImages() async {
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
      final storageRef =
          FirebaseStorage.instance.ref().child('uploads/business/$fileName');
      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _downloadUrls.add(url);
      });
    }
    carrouselUpdate();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.businessData['name']);
    phoneController = TextEditingController(text: widget.businessData['phone']);
    homeController = TextEditingController(text: widget.businessData['home']);
    descriptionController =
        TextEditingController(text: widget.businessData['description']);
    selectedCategory = widget.businessData['category'] ?? category[0];

    carrouselGet();
    _getLanguage();
    generateFourDigitToken();
    twilioService = twilioServiceKeys;
  }

  void generateFourDigitToken() {
    final random = Random();
    int number = 1000 + random.nextInt(9000);
    tokenKey = number.toString();
  }

  late final TwilioService twilioService;
  String? tokenKey;

  bool verificationModule = false;
  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {
      selectedCategory = widget.businessData['category'] ?? category[0];
    });
  }

  late List<String> data;
  void carrouselGet() {
    data = (widget.businessData['imageUrls'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();
  }

  void carrouselUpdate() {
    data = _downloadUrls;
    setState(() {});
  }

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
                    ? "Verificar su numero de telefono"
                    : "Verify your phone number",
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
                      lang! ? 'Phone' : 'Telefono',
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
                        toastF(lang!
                            ? "Telefono verificado con exito"
                            : "Phone verified successfully");
                      } else {
                        toastF(lang!
                            ? "* El token enviado no coincide"
                            : "* The sent token does not match");
                      }
                      Navigator.pop(context, verificationModule);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(width: 2.0, color: Colors.black),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Colors.black,
                        ),
                        Text(
                          lang! ? "Verificar" : "Verify",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: !_isSame,
              child: Text(
                lang!
                    ? "* El token enviado no coincide"
                    : "* The sent token does not match",
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                String phone = phoneController.text;
                String message =
                    'PET WALKS, Token de verificacion para: ${phoneController.text}\nSu token de verificacion es: $tokenKey';
                twilioService.sendSms(phone, message);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color.fromRGBO(250, 244, 229, .65), width: 2),
              ),
              child: Text(
                lang!
                    ? 'Enviar token de verificacion'
                    : 'Send verification token',
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
                lang! ? 'Exit' : 'Salir',
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
        });
      }
    });
  }

  bool isVerified = false;
  final bool _isSame = true;

  bool _isName = true;
  bool _isHome = true;
  bool _isVerified = true;

  bool sameToken(String sent) {
    return tokenKey == sent;
  }

  bool verifyFieldsName() {
    return nameController.text.isNotEmpty;
  }

  bool verifyFieldsHome() {
    return homeController.text.isNotEmpty;
  }

  bool verifyFields() {
    return verifyFieldsName() && isVerified && verifyFieldsHome();
  }

  IconData getIcon() {
    return isVerified ? Icons.verified_outlined : Icons.error_outline;
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
                children: [
                  Stack(children: [
                    titleW(title: lang! ? 'Información' : 'Information'),
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
                    Positioned(
                        left: 315,
                        top: 70,
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () => _pickImages(),
                              icon: const Icon(Icons.upload,
                                  size: 30, color: Colors.black),
                            ),
                            Text(
                              lang! ? 'Nuevas Imágenes' : 'New Images',
                              style: const TextStyle(fontSize: 10),
                            )
                          ],
                        )),
                  ]),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(),
                  Stack(children: [
                    PhotoCarousel(imageUrls: data),
                  ]),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            child: Column(
                              children: [
                                TextField(
                                    keyboardType: TextInputType.name,
                                    controller: nameController,
                                    decoration: StyleTextField(
                                        lang! ? 'Nombre' : 'Name')),
                                Visibility(
                                  visible: !_isName,
                                  child: Text(
                                    "* ${lang! ? 'Nombre no puede ser vacio' : 'Name cannot be empty'}",
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 10),
                                  ),
                                ),
                                const EmptyBox(h: 20),
                                DropdownButton<String>(
                                  value: selectedCategory,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCategory = newValue!;
                                    });
                                  },
                                  items: category.map((String cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat,
                                      child: Text(cat),
                                    );
                                  }).toList(),
                                ),
                                const EmptyBox(h: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: TextField(
                                          onChanged: (_) {
                                            setState(() {
                                              isVerified = false;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          controller: phoneController,
                                          decoration: StyleTextField(
                                            lang! ? "Telefono" : "Phone number",
                                          )),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 100,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          verifyPhone(phoneController.text);

                                          if (verificationModule) {
                                            isVerified = true;
                                            setState(() {});
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 0.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            side: const BorderSide(
                                                width: 2.0,
                                                color: Colors.black),
                                          ),
                                          backgroundColor: Colors.grey[200],
                                        ),
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
                                              lang! ? "Verificar" : "Verify",
                                              style: const TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Visibility(
                                  visible: !_isVerified,
                                  child: Text(
                                    lang!
                                        ? '* Falta verificar telefono del usuario'
                                        : '* Missing phone number verification',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 10),
                                  ),
                                ),
                                const EmptyBox(h: 20),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlinedButton(
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
                                            }
                                            setState(() {
                                              homeController.text =
                                                  domicilio.toString();
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 24.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              side: const BorderSide(
                                                  width: 2.0,
                                                  color: Colors.black),
                                            ),
                                            backgroundColor: Colors.grey[200],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(FontAwesomeIcons.home,
                                                  size: 25,
                                                  color: Colors.black),
                                              const SizedBox(width: 5),
                                              Text(
                                                lang!
                                                    ? 'Seleccionar'
                                                    : 'Select',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 18.0,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton(
                                          onPressed: () async {
                                            String domicilio = '';
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditHome(
                                                  homeToEdit:
                                                      homeController.text,
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
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 24.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              side: const BorderSide(
                                                  width: 2.0,
                                                  color: Colors.black),
                                            ),
                                            backgroundColor: Colors.grey[200],
                                          ),
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
                                              const Icon(Icons.edit,
                                                  size: 25,
                                                  color: Colors.black),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
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
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Text(
                                        lang!
                                            ? "Domicilio: ${homeController.text}"
                                            : "Address: ${homeController.text}",
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
                                  ],
                                ),
                                Visibility(
                                  visible: !_isHome,
                                  child: Text(
                                    "* ${lang! ? 'El domicilio no puede estar vacio' : 'Address cannot be empty'}",
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 10),
                                  ),
                                ),
                                const EmptyBox(h: 20),
                                TextField(
                                    keyboardType: TextInputType.multiline,
                                    controller: descriptionController,
                                    decoration: StyleTextField(
                                        lang! ? 'Descripción' : 'Description')),
                                const EmptyBox(h: 20),
                              ],
                            ))),
                  ),
                  const Divider(),
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

                              if (!isVerified) {
                                setState(() {
                                  _isVerified = false;
                                });
                              } else {
                                setState(() {
                                  _isVerified = true;
                                });
                              }

                              if (!verifyFieldsHome()) {
                                setState(() {
                                  _isHome = false;
                                });
                              } else {
                                setState(() {
                                  _isHome = true;
                                });
                              }

                              setState(() {
                                _isLoading = false;
                              });
                            } else {
                              _isName = true;
                              _isVerified = true;
                              _isHome = true;

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                await updateBusiness(
                                  widget.id,
                                  nameController.text,
                                  selectedCategory,
                                  phoneController.text,
                                  homeController.text,
                                  descriptionController.text,
                                  data,
                                );

                                toastF(lang!
                                    ? 'Se ha actualizado la informacion'
                                    : 'Information updated');
                                Navigator.pop(context);
                              } catch (e) {
                                toastF(lang!
                                    ? 'Error al actualizar la informacion'
                                    : 'Error updating information');
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                    style: customOutlinedButtonStyle(),
                    child: _isLoading
                        ? const SpinKitSpinningLines(
                            color: Color.fromRGBO(169, 200, 149, 1), size: 50.0)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.update,
                                size: 30,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text(
                                lang! ? 'Actualizar' : 'Update',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
      ),
    );
  }
}
