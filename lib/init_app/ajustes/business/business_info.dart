// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/init_app/ajustes/business/edit_business_info.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/call_comments.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class InfoBusiness extends StatefulWidget {
  final List<dynamic> imageUrls;
  final String id;
  const InfoBusiness({required this.imageUrls, required this.id, super.key});

  @override
  State<InfoBusiness> createState() => _InfoBusinessState();
}

class _InfoBusinessState extends State<InfoBusiness> {
  var fetchedInfoBusiness;
  bool? lang;
  double rating = 0;
  String? email;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _getLanguage(),
      _fetchBusinessInfo(),
      _fetchUserEmail(),
    ]);
    _calculateRating();
    setState(() {});
  }

  Future<void> _fetchBusinessInfo() async {
    fetchedInfoBusiness = await getInfoBusinessById(widget.id);
  }

  Future<void> _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {}
  }

  Future<void> _getLanguage() async {
    lang = await getLanguage();
  }

  void _calculateRating() {
    if (fetchedInfoBusiness != null) {
      List<double> ratings = (fetchedInfoBusiness['rating'] as List<dynamic>)
          .map((e) => e is int ? e.toDouble() : e as double)
          .toList();
      rating = ratings.isNotEmpty
          ? (ratings.reduce((a, b) => a + b) / ratings.length)
          : 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lang == null || fetchedInfoBusiness == null) {
      return const Scaffold(
        body: Center(
            child: SpinKitSpinningLines(
                color: Color.fromRGBO(169, 200, 149, 1), size: 50.0)),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              titleW(title: lang! ? 'Información' : 'Information'),
              Positioned(
                left: 330,
                top: 70,
                child: Column(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size: 30, color: Colors.black),
                      onPressed: () async {
                        var info = await getInfoBusinessById(widget.id);

                        var updatedPetData = await Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditInfoBusiness(
                              businessData: info,
                              id: widget.id,
                            ),
                          ),
                        );

                        if (updatedPetData != null) {
                          setState(() {
                            fetchedInfoBusiness = updatedPetData;
                            widget.imageUrls.clear();
                            widget.imageUrls
                                .addAll(updatedPetData['imageUrls']);
                          });
                        }
                      },
                    ),
                    Text(
                      lang! ? 'Editar' : 'Edit',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          PhotoCarousel(
            imageUrls: widget.imageUrls.map((item) => item.toString()).toList(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const EmptyBox(h: 15),
                  containerStyle(
                      '${lang! ? 'Nombre' : 'Name'}: ${fetchedInfoBusiness['name']}'),
                  const EmptyBox(h: 15),
                  containerStyle(
                      '${lang! ? 'Categoria' : 'Category'}: ${fetchedInfoBusiness['category']}'),
                  const EmptyBox(h: 15),
                  containerStyle(
                      '${lang! ? 'Telefono' : 'Phone'}: ${fetchedInfoBusiness['phone']}'),
                  const EmptyBox(h: 15),
                  containerStyleDescription(
                      '${lang! ? 'Descripción' : 'Description'}: ${fetchedInfoBusiness['description']}'),
                  const EmptyBox(h: 15),
                  containerStyle(
                      '${lang! ? 'Domicilio' : 'Address'}: ${fetchedInfoBusiness['address']}'),
                  const EmptyBox(h: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                rating > index ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text('$rating/5'),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showCommentsDialog(
                            context,
                            fetchedInfoBusiness['comments'],
                            'business',
                            widget.id,
                            false,
                          );
                        },
                        child: Text(
                          lang! ? 'Comentarios' : 'Comments',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
