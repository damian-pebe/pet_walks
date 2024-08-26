import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwalks_app/init_app/ajustes/pets/edit_pets_info.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/comments_dialog.dart';
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
  void showCommentsDialog(BuildContext context, List<dynamic> comments) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return CommentsDialog(comments: comments);
      },
    );
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Stack(children: [
                titleW(title: 'Informacion'),
                Positioned(
                    left: 330,
                    top: 70,
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 30, color: Colors.black),
                          onPressed: () async {
                            var infoPet = await getInfoPets(email!, widget.id);

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
                          'Editar',
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
                          'Regresar',
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    )),
              ]),
              PhotoCarousel(
                imageUrls: (widget.imageUrls as List<dynamic>)
                    .map((item) => item.toString())
                    .toList(),
              ),
              const EmptyBox(h: 10),
              containerStyle('Nombre: ${widget.petData['name']}'),
              const EmptyBox(h: 20),
              containerStyle('Raza: ${widget.petData['race']}'),
              const EmptyBox(h: 20),
              containerStyle('Tamaño: ${widget.petData['size']}'),
              const EmptyBox(h: 20),
              containerStyle('Descripcion: ${widget.petData['description']}'),
              const EmptyBox(h: 20),
              containerStyle('Edad: ${widget.petData['old']}'),
              const EmptyBox(h: 20),
              containerStyle('Color: ${widget.petData['color']}'),
              const EmptyBox(h: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                              widget.petData['rating'] > 0
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber),
                          Icon(
                              widget.petData['rating'] > 1
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber),
                          Icon(
                              widget.petData['rating'] > 2
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber),
                          Icon(
                              widget.petData['rating'] > 3
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber),
                          Icon(
                              widget.petData['rating'] > 4
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      Text('${widget.petData['rating']}/5'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showCommentsDialog(context, widget.petData['comments']);
                    },
                    child: Text(
                      "Comentarios",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
