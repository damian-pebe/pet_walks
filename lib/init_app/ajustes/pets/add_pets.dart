import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    } else {
      print('Error getting email from user');
    }
  }

  late String lastPetId;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 15, right: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImages,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _downloadUrls.isNotEmpty
                  ? NetworkImage(_downloadUrls[0])
                  : null,
              child: _downloadUrls.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          EmptyBox(h: 15),
          TextField(
              keyboardType: TextInputType.name,
              controller: nameController,
              decoration: StyleTextField('Nombre')),
          VisibilityW(boolean: _isName, string: "Falta nombre de la mascota"),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                      keyboardType: TextInputType.name,
                      controller: raceController,
                      decoration: StyleTextField('Raza')),
                  EmptyBox(h: 15),
                  TextField(
                      keyboardType: TextInputType.number,
                      controller: sizeController,
                      decoration: StyleTextField('Tamaño en cm')),
                  EmptyBox(h: 15),
                  TextField(
                      keyboardType: TextInputType.name,
                      controller: descriptionController,
                      decoration:
                          StyleTextField('Caracteristicas/Comentarios')),
                  EmptyBox(h: 15),
                  TextField(
                      keyboardType: TextInputType.number,
                      controller: oldController,
                      decoration: StyleTextField('Edad')),
                  EmptyBox(h: 15),
                  TextField(
                      keyboardType: TextInputType.name,
                      controller: colorController,
                      decoration: StyleTextField('Color de mascota')),
                  const EmptyBox(h: 15),
                  VisibilityW(
                      boolean: _isPics,
                      string: "Faltan imagenes de la mascota"),
                ],
              ),
            ),
          ),
          Divider(),
          OutlinedButton(
            onPressed: () async {
              if (!verifyFields()) {
                if (!verifyFieldsName()) {
                  _isName = false;
                  setState(() {});
                } else {
                  _isName = true;
                  setState(() {});
                }
                if (!verifyFieldsPics()) {
                  _isPics = false;
                  setState(() {});
                } else {
                  _isPics = true;
                  setState(() {});
                }
              } else {
                save() async {
                  lastPetId = await newPet(
                      nameController.text,
                      raceController.text,
                      sizeController.text,
                      descriptionController.text,
                      oldController.text,
                      colorController.text,
                      _downloadUrls);
                  await addPetToUser(email!, lastPetId);
                }

                save();
                toastF('La mascota ha sido agregada');
                clear();
              }
            },
            style: customOutlinedButtonStyle(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets_sharp,
                  size: 30,
                  color: Colors.black,
                ),
                SizedBox(width: 30),
                Text(
                  'Agregar mascota',
                  style: TextStyle(
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
    );
  }
}
