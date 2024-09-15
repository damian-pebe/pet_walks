import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class EditInfoPet extends StatefulWidget {
  final Map<String, dynamic> petData;
  final String id;
  const EditInfoPet({required this.petData, required this.id, super.key});

  @override
  State<EditInfoPet> createState() => _EditInfoPet();
}

class _EditInfoPet extends State<EditInfoPet> {
  bool _isLoading = false;

  late TextEditingController nameController;
  late TextEditingController raceController;
  late TextEditingController sizeController;
  late TextEditingController descriptionController;
  late TextEditingController oldController;
  late TextEditingController colorController;

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
    carrouselUpdate();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.petData['name']);
    raceController = TextEditingController(text: widget.petData['race']);
    sizeController = TextEditingController(text: widget.petData['size']);
    descriptionController =
        TextEditingController(text: widget.petData['description']);
    oldController = TextEditingController(text: widget.petData['old']);
    colorController = TextEditingController(text: widget.petData['color']);
    carrouselGet();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  late List<String> data;
  void carrouselGet() {
    data = (widget.petData['imageUrls'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();
  }

  void carrouselUpdate() {
    data = _downloadUrls;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
      home: Scaffold(
        body: lang == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
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
                                icon: Icon(Icons.arrow_back_ios,
                                    size: 30, color: Colors.black),
                              ),
                              Text(
                                lang! ? 'Regresar' : 'Back',
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )),
                      Positioned(
                          left: 300,
                          top: 70,
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () => _pickImages(),
                                icon: Icon(Icons.upload,
                                    size: 30, color: Colors.black),
                              ),
                              Text(
                                lang! ? 'Nuevas Imágenes' : 'New Images',
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )),
                    ]),
                    const Divider(),
                    Stack(children: [
                      PhotoCarousel(imageUrls: data),
                    ]),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              child: Column(
                                children: [
                                  TextField(
                                      keyboardType: TextInputType.name,
                                      controller: nameController,
                                      decoration: StyleTextField(
                                          lang! ? 'Nombre' : 'Name')),
                                  const EmptyBox(h: 20),
                                  TextField(
                                      keyboardType: TextInputType.name,
                                      controller: raceController,
                                      decoration: StyleTextField(
                                          lang! ? 'Raza' : 'Breed')),
                                  const EmptyBox(h: 20),
                                  TextField(
                                      keyboardType: TextInputType.number,
                                      controller: sizeController,
                                      decoration: StyleTextField(
                                          lang! ? 'Tamaño(cm)' : 'Size(cm)')),
                                  const EmptyBox(h: 20),
                                  TextField(
                                      keyboardType: TextInputType.multiline,
                                      controller: descriptionController,
                                      decoration: StyleTextField(lang!
                                          ? 'Descripción'
                                          : 'Description')),
                                  const EmptyBox(h: 20),
                                  TextField(
                                      keyboardType: TextInputType.number,
                                      controller: oldController,
                                      decoration: StyleTextField(
                                          lang! ? 'Edad(años)' : 'Age(years)')),
                                  const EmptyBox(h: 20),
                                  TextField(
                                      keyboardType: TextInputType.name,
                                      controller: colorController,
                                      decoration: StyleTextField(
                                          lang! ? 'Color' : 'Color')),
                                  const EmptyBox(h: 20),
                                ],
                              ))),
                    ),
                    Divider(),
                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (nameController.text.isEmpty || data.isEmpty) {
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                await updatePet(
                                  widget.id,
                                  nameController.text,
                                  raceController.text,
                                  sizeController.text,
                                  descriptionController.text,
                                  oldController.text,
                                  colorController.text,
                                  data,
                                );

                                List<double> ratings = (widget.petData['rating']
                                        as List<dynamic>)
                                    .map((e) =>
                                        e is int ? e.toDouble() : e as double)
                                    .toList();
                                double rating = ratings.isNotEmpty
                                    ? (ratings.reduce((a, b) => a + b) /
                                        ratings.length)
                                    : 0.0;

                                final updatedPetData = {
                                  'name': nameController.text,
                                  'race': raceController.text,
                                  'size': sizeController.text,
                                  'description': descriptionController.text,
                                  'old': oldController.text,
                                  'color': colorController.text,
                                  'imageUrls': data,
                                  'rating': rating,
                                  'comments': widget.petData['comments'],
                                };

                                toastF(lang!
                                    ? 'Se ha actualizado la información'
                                    : 'Information updated');
                                Navigator.pop(context, updatedPetData);
                              } catch (e) {
                                toastF(lang!
                                    ? 'Error al actualizar la información'
                                    : 'Error updating information');
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                      style: customOutlinedButtonStyle(),
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.update,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  lang! ? 'Actualizar' : 'Update',
                                  style: TextStyle(
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
              ),
      ),
    );
  }
}
