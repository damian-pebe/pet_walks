// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'dart:convert';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/widgets/toast.dart';

class EditHome extends StatefulWidget {
  final String? homeToEdit;

  const EditHome({super.key, this.homeToEdit});

  @override
  State<EditHome> createState() => _EditHomeState();
}

class _EditHomeState extends State<EditHome> {
  bool lang = true;
  void _getLanguage() async {
    if (await isUserLoggedIn()) {
      lang = await getLanguage();
      if (mounted) setState(() {});
    } else {
      bool savedLang = await getLanguagePreference();
      setState(() {
        lang = savedLang;
      });
    }
  }

  Future<bool> isUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  late TextEditingController homeController;
  late String apiKey = googleAPIKey; // Coloca tu API Key aquí

  @override
  void initState() {
    super.initState();
    homeController = TextEditingController(text: widget.homeToEdit);

    _getLanguage();
  }

  @override
  void dispose() {
    homeController.dispose();
    super.dispose();
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['predictions'] != null) {
        return List<String>.from(
            result['predictions'].map((p) => p['description']));
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  titleW(
                    title: lang ? 'Editar domicilio' : 'Edit adress',
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
                            lang ? 'Regresar' : 'Back',
                            style: const TextStyle(fontSize: 10),
                          )
                        ],
                      )),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: homeController,
                      decoration: StyleTextField(
                        lang ? 'Domicilio' : 'Address',
                      )),
                  suggestionsCallback: (pattern) async {
                    return await _getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    homeController.text = suggestion;
                  },
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              OutlinedButton(
                onPressed: () async {
                  nav() {
                    Navigator.pop(context, {
                      'domicilio': widget.homeToEdit,
                    });
                  }

                  LatLng? selected =
                      await getLatLngFromAddress(widget.homeToEdit!);
                  LatLng? edited =
                      await getLatLngFromAddress(homeController.text);
                  double distanceInMeters;
                  if (selected != null && edited != null) {
                    distanceInMeters = Geolocator.distanceBetween(
                      selected.latitude,
                      selected.longitude,
                      edited.latitude,
                      edited.longitude,
                    );
                  } else {
                    distanceInMeters = -1;
                  }
                  if (distanceInMeters > 0) {
                    if (distanceInMeters > 400) {
                      toastF(lang
                          ? 'El domicilio editado esta demaciado lejos del seleccionado, vuelva a intentar'
                          : 'The edited address is too far from the selected one, try again');
                    } else {
                      toastF(lang
                          ? 'Domicilio editado con exito'
                          : 'Address edited successfully');
                      nav();
                    }
                  } else {
                    toastF(lang
                        ? 'No se puede editar este domicilio'
                        : 'Cannot edit this address');
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 55.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(width: 2.0, color: Colors.black),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang ? 'Aceptar' : 'Accept',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.check_box_outlined,
                      size: 25,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/logo.png',
                width: 300,
                height: 300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
