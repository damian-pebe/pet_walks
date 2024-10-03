import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  String? fileNameAddress;
  String? fileNameINE;

  Future<String?> uploadFileAndSaveUrl(bool select) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        // select ? downloadUrlAddress = fileName : downloadUrlINE = fileName;
        select ? fileNameAddress = fileName : fileNameINE = fileName;

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
              ? const Center(
                  child: SpinKitSpinningLines(
                      color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          titleW(
                            title: lang! ? 'Contrato' : 'Agreement',
                          ),
                          Positioned(
                              left: 30,
                              top: 70,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.arrow_back_ios,
                                    size: 30, color: Colors.black),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(lang!
                            ? 'Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,Para utilizar los servicios y brindar seguridad a los usuarios...,'
                            : 'To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,To use the services and provide security to users...,'),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              lang!
                                  ? 'INE vigente que contenga domicilio'
                                  : 'Current INE that contains an address',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Image.asset('assets/agreement/ine.png', height: 240),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          lang!
                              ? 'Archivo seleccionado: $fileNameINE'
                              : 'Selected file: $fileNameINE',
                          style: const TextStyle(
                              fontSize: 14, fontStyle: FontStyle.italic),
                        ),
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
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              lang!
                                  ? 'Comprobante de domicilio, maximo de 3 meses'
                                  : 'Address proof, maximum of  3 months',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Image.asset('assets/agreement/address_proof.png',
                              height: 240),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          lang!
                              ? 'Archivo seleccionado: $fileNameAddress'
                              : 'Selected file: $fileNameAddress',
                          style: const TextStyle(
                              fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                          onPressed: () async {
                            downloadUrlAddress =
                                await uploadFileAndSaveUrl(true);
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

                              await uploadAgreementUserStatus(
                                  idUser!, 'inCheck');

                              toastF(lang!
                                  ? 'Documentos enviados para su revision'
                                  : 'Documents sent for checkin');
                              Navigator.pop(context);
                              setState(() {});
                            }
                          },
                          style: customOutlinedButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                        height: 25,
                      ),
                    ],
                  ),
                ),
        ));
  }
}
