// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
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

  bool? premium;
  void statusPremiumInstance() async {
    premium = await getPremiumStatus(email);
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
    statusPremiumInstance();
  }

  TextEditingController descriptionController = TextEditingController(text: "");

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
      final storageRef =
          FirebaseStorage.instance.ref().child('uploads/PostsImages/$fileName');
      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _downloadUrls.add(url);
      });
    }
    setState(() {});
  }

  bool isToggled = false;
  String type = 'Extravio';
  String isToggledText() {
    isToggled ? type = 'Extravio' : type = 'Adopcion';
    return type;
  }

  bool _isLoading = false;
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
                      Stack(
                        children: [
                          titleW(
                            title: lang! ? 'Publicar' : 'Post',
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
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggled = !isToggled;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: 90,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: isToggled
                                          ? const Color.fromARGB(
                                              100, 169, 200, 149)
                                          : const Color.fromARGB(
                                              255, 169, 200, 149),
                                    ),
                                    child: Stack(
                                      children: [
                                        AnimatedPositioned(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          curve: Curves.easeIn,
                                          left: isToggled ? 50 : 0,
                                          right: isToggled ? 0 : 50,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: Icon(
                                              isToggled
                                                  ? FontAwesomeIcons.lowVision
                                                  : FontAwesomeIcons.heart,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  isToggledText() == 'Adopcion'
                                      ? (lang! ? 'Adopcion' : 'Adoption')
                                      : (lang! ? 'Extravio' : 'Stray'),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
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
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 250,
                              child: TextField(
                                  controller: descriptionController,
                                  maxLines: 6,
                                  keyboardType: TextInputType.multiline,
                                  decoration: StyleTextField(
                                      lang! ? 'Descripcion' : 'Description')),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            _isLoading
                                ? const SpinKitSpinningLines(
                                    color: Color.fromRGBO(169, 200, 149, 1),
                                    size: 50.0)
                                : OutlinedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            setState(() {
                                              _isLoading = true;
                                            });

                                            await _uploadImages();

                                            save() async {
                                              String lastPostId = await newPost(
                                                descriptionController.text,
                                                _downloadUrls,
                                                type,
                                              );
                                              await addPostToUser(
                                                  email, lastPostId);
                                            }

                                            await save();
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            Navigator.pop(context, true);
                                          },
                                    style: customOutlinedButtonStyle(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.public,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Text(
                                          lang! ? 'Publicar' : 'Post',
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                      ],
                                    )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
