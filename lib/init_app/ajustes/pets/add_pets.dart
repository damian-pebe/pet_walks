import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/toast.dart';
import 'package:petwalks_app/widgets/visibility.dart';

class AddPets extends StatefulWidget {
  const AddPets({super.key});

  @override
  State<AddPets> createState() => _AddPetsState();
}

class _AddPetsState extends State<AddPets> {
  bool _isLoading = false;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController raceController = TextEditingController(text: "");
  TextEditingController sizeController = TextEditingController(text: "");
  TextEditingController oldController = TextEditingController(text: "");
  TextEditingController colorController = TextEditingController(text: "");
  TextEditingController descriptionController = TextEditingController(text: "");
  List<File> _imageFiles = [];
  List<String> _downloadUrls = [];

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
          FirebaseStorage.instance.ref().child('uploads/petImages/$fileName');
      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _downloadUrls.add(url);
      });
    }
  }

  String? email;
  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {}
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  // Verification Fields
  bool verifyFieldsName() {
    if (nameController.text == "") return false;
    return true;
  }

  bool verifyFieldsPics() {
    if (_downloadUrls.isEmpty) return false;
    return true;
  }

  bool verifyFields() {
    if (!verifyFieldsName()) return false;
    if (!verifyFieldsPics()) return false;
    return true;
  }

  bool _isName = true;
  bool _isPics = true;

  void clear() {
    nameController = TextEditingController(text: "");
    raceController = TextEditingController(text: "");
    sizeController = TextEditingController(text: "");
    oldController = TextEditingController(text: "");
    colorController = TextEditingController(text: "");
    descriptionController = TextEditingController(text: "");
    _imageFiles = [];
    _downloadUrls = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 15, right: 15),
      child: lang == null
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
          : Column(
              children: [
                GestureDetector(
                  onTap: _pickImages,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _downloadUrls.isNotEmpty
                        ? NetworkImage(_downloadUrls[0])
                        : null,
                    child: _downloadUrls.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const EmptyBox(h: 15),
                TextField(
                    keyboardType: TextInputType.name,
                    controller: nameController,
                    decoration: StyleTextField(lang! ? 'Nombre' : 'Name')),
                VisibilityW(
                    boolean: _isName,
                    string: lang!
                        ? "Falta nombre de la mascota"
                        : "Pet name missing"),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                            keyboardType: TextInputType.name,
                            controller: raceController,
                            decoration:
                                StyleTextField(lang! ? 'Raza' : 'Race')),
                        const EmptyBox(h: 15),
                        TextField(
                            keyboardType: TextInputType.number,
                            controller: sizeController,
                            decoration: StyleTextField(
                                lang! ? 'Tamaño en cm' : 'Size in cm')),
                        const EmptyBox(h: 15),
                        TextField(
                            keyboardType: TextInputType.name,
                            controller: descriptionController,
                            decoration: StyleTextField(lang!
                                ? 'Caracteristicas/Comentarios'
                                : 'Characteristics/Comments')),
                        const EmptyBox(h: 15),
                        TextField(
                            keyboardType: TextInputType.number,
                            controller: oldController,
                            decoration: StyleTextField(lang! ? 'Edad' : 'Age')),
                        const EmptyBox(h: 15),
                        TextField(
                            keyboardType: TextInputType.name,
                            controller: colorController,
                            decoration: StyleTextField(
                                lang! ? 'Color de mascota' : 'Pet Color')),
                        const EmptyBox(h: 15),
                        VisibilityW(
                            boolean: _isPics,
                            string: lang!
                                ? "Faltan imagenes de la mascota"
                                : "Pet images missing"),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });

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

                            if (!verifyFieldsPics()) {
                              setState(() {
                                _isPics = false;
                              });
                            } else {
                              setState(() {
                                _isPics = true;
                              });
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          } else {
                            Future<void> save() async {
                              String lastPetId = await newPet(
                                nameController.text,
                                raceController.text,
                                sizeController.text,
                                descriptionController.text,
                                oldController.text,
                                colorController.text,
                                _downloadUrls,
                              );
                              await addPetToUser(email!, lastPetId);
                            }

                            await save();

                            setState(() {
                              _isLoading = false;
                            });

                            toastF(lang!
                                ? 'La mascota ha sido agregada'
                                : 'Pet has been added');
                            clear();
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
                              Icons.pets_sharp,
                              size: 30,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 30),
                            Text(
                              lang! ? 'Agregar mascota' : 'Add Pet',
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
              ],
            ),
    );
  }
}
