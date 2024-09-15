import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({super.key});

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  late Future<List<String>> futureSuggestions;
  TextEditingController suggestionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFutures();
    _getLanguage();
  }

  String? email;
  bool? lang;

  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  Future<void> _initializeFutures() async {
    email = await fetchUserEmail();
    futureSuggestions = getSuggestions();
    if (mounted) setState(() {});
  }

  Future<List<String>> getSuggestions() async {
    var doc = await FirebaseFirestore.instance
        .collection('suggestions')
        .doc('suggestions')
        .get();

    List<String> suggestions =
        List<String>.from(doc.data()?['suggestions'] ?? []);

    return suggestions;
  }

  void _refreshData() {
    setState(() {
      futureSuggestions = getSuggestions();
    });
  }

  void addSuggestionAndRefresh(String suggestion) async {
    await addSuggestion(suggestion);
    _refreshData();
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
                      titleW(title: lang! ? 'Sugerencias' : 'Suggestions'),
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
                  Expanded(
                    child: FutureBuilder<List<String>>(
                      future: futureSuggestions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(lang!
                                  ? 'No hay sugerencias disponibles'
                                  : 'No suggestions available'));
                        } else {
                          List<String> suggestions = snapshot.data!;
                          return ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.account_circle_outlined,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      suggestions[index],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: suggestionController,
                            decoration: InputDecoration(
                              hintText: lang!
                                  ? 'Agregar una nueva sugerencia...'
                                  : 'Add a new suggestion...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.black),
                          onPressed: () {
                            if (suggestionController.text.isNotEmpty) {
                              addSuggestionAndRefresh(
                                  suggestionController.text);
                              suggestionController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
