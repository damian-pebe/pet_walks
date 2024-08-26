import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'dart:convert';
import 'package:petwalks_app/widgets/titleW.dart';

class EditHome extends StatefulWidget {
  final String? homeToEdit;

  const EditHome({Key? key, this.homeToEdit}) : super(key: key);

  @override
  State<EditHome> createState() => _EditHomeState();
}

class _EditHomeState extends State<EditHome> {
  late TextEditingController homeController;
  late String apiKey = googleAPIKey; // Coloca tu API Key aquí

  @override
  void initState() {
    super.initState();
    homeController = TextEditingController(text: widget.homeToEdit);
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
      theme:
          ThemeData(scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1)),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              titleW(title: 'Editar domicilio'),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: homeController,
                      decoration: StyleTextField('Domicilio')),
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
              SizedBox(
                height: 50,
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'domicilio': homeController.text,
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 55.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(width: 2.0, color: Colors.black),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Aceptar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
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
