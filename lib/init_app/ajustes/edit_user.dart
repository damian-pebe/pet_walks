import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/home/editHome.dart';
import 'package:petwalks_app/pages/opciones/home/selectHome.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController homeController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();

  String inTokenPhone = '1234';
  String tokenSent = '';
  bool verificationModule = false;

  String homelatlng = '';

  bool _obscureText = true;
  bool _obscureText1 = true;

  bool isVerified = false;
  bool isPrivacity = false;
  final bool _isSame = true;

  File? _imageFile;
  String _downloadUrl = '';

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
    await _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final fileName = path.basename(_imageFile!.path);
    final storageRef =
        FirebaseStorage.instance.ref().child('uploads/profilePhotos/$fileName');
    await storageRef.putFile(_imageFile!);
    final url = await storageRef.getDownloadURL();
    setState(() {
      _downloadUrl = url;
    });
  }

  Future<void> fetchAndSetUserData(String email) async {
    print('Fetching data for email: $email');
    UserService userService = UserService();
    Set<Map<String, dynamic>> userData = await userService.getUser(email);
    print("Fetched User Data: $userData");

    if (userData.isNotEmpty) {
      var user = userData.first;
      setState(() {
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? email;
        phoneController.text = user['phone'] ?? '';
        homeController.text = user['address'] ?? '';
      });
    } else {
      setState(() {
        nameController.text = '';
        emailController.text = email;
        phoneController.text = '';
        homeController.text = '';
      });
    }

    print(
        "Controllers updated: ${nameController.text}, ${emailController.text}, ${phoneController.text}, ${homeController.text}");
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchAndSetUserData(user.email!);
      }
    });
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleVisibility1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  bool sameToken(String sent) {
    return inTokenPhone == sent;
  }

  bool verifyFieldsName() {
    return nameController.text.isNotEmpty;
  }

  bool verifyFieldsEmail() {
    return emailController.text.isNotEmpty;
  }

  bool verifyFieldsHome() {
    return homeController.text.isNotEmpty;
  }

  bool verifyFields() {
    return verifyFieldsName() &&
        verifyFieldsEmail() &&
        isVerified &&
        verifyFieldsHome();
  }

  IconData getIcon() {
    return isVerified ? Icons.verified_outlined : Icons.error_outline;
  }

  IconData getIconPrivacity() {
    setState(() {});
    return isPrivacity ? Icons.check : Icons.not_interested;
  }

  void verifyPhone(String numberPhone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Verificar su numero de telefono",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Icon(
                Icons.send,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
          backgroundColor: Color.fromRGBO(250, 244, 229, 1),
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
                      decoration: StyleTextField('Telefono')),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () {
                      if (sameToken(tokenController.text)) {
                        verificationModule = true;
                        toastF("Telefono verificado con exito");
                      } else {
                        toastF("* El token enviado no coincide");
                      }
                      Navigator.pop(context, verificationModule);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(width: 2.0, color: Colors.black),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: Colors.black,
                        ),
                        Text(
                          "Verificar",
                          style: TextStyle(color: Colors.black, fontSize: 10),
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
              child: const Text(
                "* El token enviado no coincide",
                style: TextStyle(color: Colors.red, fontSize: 10),
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
                'Enviar token de verificacion',
                style: TextStyle(
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
                'Salir',
                style: TextStyle(fontSize: 13, color: Colors.black),
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

  bool _isName = true;
  bool _isHome = true;
  bool _isVerified = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    const titleW(title: 'Editar'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          emailController.text,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey[800],
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
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: _downloadUrl.isNotEmpty
                              ? NetworkImage(_downloadUrl)
                              : null,
                          child: _downloadUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                          keyboardType: TextInputType.name,
                          controller: nameController,
                          decoration: StyleTextField('Nombre')),
                      Visibility(
                        visible: !_isName,
                        child: Text(
                          "* Nombre no puede ser vacio",
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 250,
                            child: TextField(
                                onChanged: (_) {
                                  setState(() {
                                    isVerified = false;
                                  });
                                },
                                keyboardType: TextInputType.number,
                                controller: phoneController,
                                decoration: StyleTextField('Telefono')),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 90,
                            child: OutlinedButton(
                              onPressed: () {
                                if (isVerified) {
                                  toastF('Numero ya verificacdo');
                                  return;
                                }

                                verifyPhone(phoneController.text);

                                if (verificationModule) {
                                  isVerified = true;
                                  setState(() {});
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 0.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                      width: 2.0, color: Colors.black),
                                ),
                                backgroundColor: Colors.grey[200],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    getIcon(),
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    'Verificacion',
                                    style: TextStyle(
                                        fontSize: 8, color: Colors.black),
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
                          "* Debe verificar el nuevo telefono ",
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
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
                                    builder: (context) => SelectHome(),
                                  ),
                                );

                                if (result != null) {
                                  domicilio = result['domicilio'];
                                  print('\nDOMICILIO: ' + domicilio);
                                }
                                setState(() {
                                  homeController.text = domicilio.toString();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 24.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                      width: 2.0, color: Colors.black),
                                ),
                                backgroundColor: Colors.grey[200],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.home,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Modificar\ndomicilio',
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
                                  print('\nDOMICILIO: ' + domicilio);
                                }
                                setState(() {
                                  homeController.text = domicilio.toString();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 24.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                      width: 2.0, color: Colors.black),
                                ),
                                backgroundColor: Colors.grey[200],
                              ),
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
                                  Icon(
                                    Icons.edit,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ],
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                        visible: !_isHome,
                        child: Text(
                          "* El domicilio no puede estar vacio",
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
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
                      const SizedBox(
                        height: 30,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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

                                  // Reset loading state if fields are not verified
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } else {
                                  _isName = true;
                                  _isVerified = true;
                                  _isHome = true;

                                  // Define and run asynchronous methods
                                  Future<void> uploadImage() async {
                                    await _uploadImage();
                                  }

                                  Future<void> save() async {
                                    await modifyUser(
                                      nameController.text,
                                      emailController.text,
                                      phoneController.text,
                                      homeController.text,
                                      _downloadUrl,
                                    );
                                  }

                                  await uploadImage();
                                  await save();

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  toastF('Datos modificados con exito');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Funcion(),
                                    ),
                                  );
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                                width: 2.0, color: Colors.black),
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.signInAlt,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    'Guardar cambios',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(
                        height: 10,
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
