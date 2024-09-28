import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Agreement extends StatefulWidget {
  const Agreement({super.key});

  @override
  State<Agreement> createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  String? downloadUrlAddress;
  String? downloadUrlINE;

  Future<String?> uploadFileAndSaveUrl(bool select) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        select ? downloadUrlAddress = fileName : downloadUrlINE = fileName;

        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('uploads/documents')
            .child(fileName);
        firebase_storage.UploadTask uploadTask = ref.putFile(file);
        await uploadTask.whenComplete(() => null);

        String downloadURL = await ref.getDownloadURL();

        return downloadURL;
      } else {
        print('User canceled file picking');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  String? email;
  String? idUser;

  @override
  void initState() {
    super.initState();
    _getLanguage();

    fetchData();
  }

  fetchData() async {
    email = await fetchUserEmail();
    print('email: $email');
    idUser = await findMatchingUserId(email!);
    print('iduser: $idUser');

    setState(() {});
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
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
              : Column(
                  children: [
                    Stack(
                      children: [
                        titleW(
                          title: lang! ? 'Contrato' : 'Agreement',
                        ),
                        Positioned(
                            left: 30,
                            top: 70,
                            child: Center(
                              child: Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.arrow_back_ios,
                                        size: 30, color: Colors.black),
                                  ),
                                  Text(
                                    lang! ? 'Regresar  ' : 'Back  ',
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(lang!
                          ? 'Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,'
                          : 'To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang!
                              ? 'INE vigente\nque contenga\ndomicilio'
                              : 'Current INE\nthat contains\nan address',
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Image.asset('assets/agreement/ine.png', height: 150),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                        onPressed: () async {
                          downloadUrlINE = await uploadFileAndSaveUrl(false);
                          setState(() {});
                        },
                        style: customOutlinedButtonStyle(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.file_present_outlined,
                              size: 25,
                              color: Colors.black,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              lang! ? 'Subir archivo INE' : 'Upload file INE',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )),
                    if (downloadUrlINE != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          '$downloadUrlINE',
                          style: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/agreement/address_proof.png',
                              height: 150),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            lang!
                                ? 'Comprobante de\ndomicilio,\nmaximo de\n3 meses'
                                : 'Address proof,\nmaximum of\n 3 months',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                        onPressed: () async {
                          downloadUrlAddress = await uploadFileAndSaveUrl(true);
                          setState(() {});
                        },
                        style: customOutlinedButtonStyle(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang!
                                  ? 'Subir archivo Comprobante'
                                  : 'Upload file Proof',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.file_upload,
                              size: 25,
                              color: Colors.black,
                            ),
                          ],
                        )),
                    if (downloadUrlAddress != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          '$downloadUrlAddress',
                          style: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: OutlinedButton(
                        onPressed: () async {
                          if (downloadUrlINE == null ||
                              downloadUrlAddress == null) {
                            toastF(lang!
                                ? 'Ambos documentos dedben ser adjuntos'
                                : 'Both files should be attached');
                          } else {
                            await updateINEUser(downloadUrlINE!, idUser!);
                            await updateAdressProofUser(
                                downloadUrlAddress!, idUser!);

                            await uploadAgreementUserStatus(idUser!, 'inCheck');
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        style: customOutlinedButtonStyle(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Icon(
                              Icons.fact_check,
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
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
        ));
  }
}
