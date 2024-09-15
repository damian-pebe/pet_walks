import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwalks_app/init_app/ajustes/pets/edit_pets_info.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/call_comments.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class InfoPet extends StatefulWidget {
  final Map<String, dynamic> petData;
  final List<dynamic> imageUrls;
  final String id;
  const InfoPet(
      {required this.petData,
      required this.imageUrls,
      required this.id,
      super.key});

  @override
  State<InfoPet> createState() => _InfoPetState();
}

class _InfoPetState extends State<InfoPet> {
  String? email;
  Future<String> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {
      print('Error getting email from user');
    }
    return email ?? 'Error fetching the email';
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    ratingInit();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  double rating = 0;
  ratingInit() {
    List<double> ratings = (widget.petData['rating'] as List<dynamic>)
        .map((e) => e is int ? e.toDouble() : e as double)
        .toList();
    rating = ratings.isNotEmpty
        ? (ratings.reduce((a, b) => a + b) / ratings.length)
        : 0.0;
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
                          left: 330,
                          top: 70,
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    size: 30, color: Colors.black),
                                onPressed: () async {
                                  var infoPet =
                                      await getInfoPets(email!, widget.id);

                                  var updatedPetData = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditInfoPet(
                                        petData: infoPet,
                                        id: widget.id,
                                      ),
                                    ),
                                  );

                                  if (updatedPetData != null) {
                                    setState(() {
                                      widget.petData.clear();
                                      widget.petData.addAll(updatedPetData);
                                      widget.imageUrls.clear();
                                      widget.imageUrls
                                          .addAll(updatedPetData['imageUrls']);
                                    });
                                  }
                                },
                              ),
                              Text(
                                lang! ? 'Editar' : 'Edit',
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )),
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
                    ]),
                    PhotoCarousel(
                      imageUrls: (widget.imageUrls)
                          .map((item) => item.toString())
                          .toList(),
                    ),
                    SingleChildScrollView(
                        child: Column(
                      children: [
                        const EmptyBox(h: 8),
                        containerStyle(
                            '${lang! ? 'Nombre' : 'Name'}: ${widget.petData['name']}'),
                        const EmptyBox(h: 8),
                        containerStyle(
                            '${lang! ? 'Raza' : 'Breed'}: ${widget.petData['race']}'),
                        const EmptyBox(h: 8),
                        containerStyle(
                            '${lang! ? 'Tamaño' : 'Size'}: ${widget.petData['size']} cm'),
                        const EmptyBox(h: 8),
                        containerStyleDescription(
                            '${lang! ? 'Descripción' : 'Description'}: ${widget.petData['description']}'),
                        const EmptyBox(h: 8),
                        containerStyle(
                            '${lang! ? 'Edad' : 'Age'}: ${widget.petData['old']} años'),
                        const EmptyBox(h: 8),
                        containerStyle(
                            '${lang! ? 'Color' : 'Color'}: ${widget.petData['color']}'),
                        const EmptyBox(h: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        rating > 0
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber),
                                    Icon(
                                        rating > 1
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber),
                                    Icon(
                                        rating > 2
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber),
                                    Icon(
                                        rating > 3
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber),
                                    Icon(
                                        rating > 4
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber),
                                  ],
                                ),
                                const SizedBox(width: 8.0),
                                Text('$rating/5'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                showCommentsDialog(
                                    context,
                                    widget.petData['comments'],
                                    'pets',
                                    widget.id,
                                    false);
                              },
                              child: Text(
                                lang! ? 'Comentarios' : 'Comments',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
              ),
      ),
    );
  }
}
