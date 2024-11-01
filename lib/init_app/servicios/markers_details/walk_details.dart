// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/init_app/servicios/markers_details/place_view.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/services/twilio.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/call_comments.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/decorations.dart';

class WalkDetails extends StatefulWidget {
  final String payMethod;
  final int price;
  final String walkWFriends;
  final String timeWalking;
  final String place;
  final String description;
  final List<String> selectedPets;
  final String travelTo;
  final GeoPoint travelToPosition;
  final String ownerEmail;
  final String id;
  final String? idBusiness;

  const WalkDetails({
    required this.payMethod,
    required this.price,
    required this.walkWFriends,
    required this.timeWalking,
    required this.place,
    required this.description,
    required this.selectedPets,
    required this.travelTo,
    required this.travelToPosition,
    required this.ownerEmail,
    required this.id,
    this.idBusiness,
    super.key,
  });

  @override
  State<WalkDetails> createState() => _WalkDetailsState();
}

class _WalkDetailsState extends State<WalkDetails> {
  bool _isLoading = false;
  Map<String, dynamic> showData = {};
  Map<String, dynamic> showDatas = {};

  late List<String> idPets;

  late String email;
  void _email() async {
    email = await fetchUserEmail();
    _fetchBuilderInfo();
  }

  @override
  void initState() {
    super.initState();
    idPets = List<String>.from(widget.selectedPets);
    _email();
    _getLanguage();
    twilioService = twilioServiceKeys;
  }

  late final TwilioService twilioService;

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  void _fetchBuilderInfo() async {
    showData = await fetchBuilderInfo(idPets);
    showDatas = await fetchBuilderInfos(idPets);
    if (idPets.isNotEmpty) {
      getInfoFirstCarrousel();
    }
    setState(() {});
  }

  Future<List<String>> _array() async {
    return idPets;
  }

  Future<void> updateInfoCarrousel(List<dynamic> imageUrls,
      List<dynamic> commentsPets, double rating, String name) async {
    setState(() {
      this.imageUrls = List<String>.from(imageUrls);
      this.commentsPets = List<String>.from(commentsPets);
      this.rating = rating;
      this.name = name;
    });
  }

  void getInfoFirstCarrousel() {
    var id = idPets[0];
    var temp = showDatas[id];

    List<double> ratings = (temp['rating'] as List<dynamic>)
        .map((e) => e is int ? e.toDouble() : e as double)
        .toList();
    double rating = ratings.isNotEmpty
        ? (ratings.reduce((a, b) => a + b) / ratings.length)
        : 0.0;
    List<dynamic> imageUrls = temp['imageUrls'];
    List<dynamic> commentsPets = temp['comments'];
    String name = temp['name'];

    updateInfoCarrousel(imageUrls, commentsPets, rating, name);
  }

  List<String> imageUrls = [];
  List<String> commentsPets = [];
  double rating = 0.0;
  String name = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: lang == null
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
          : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color.fromARGB(245, 255, 255, 255),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.timeWalking != ''
                          ? lang!
                              ? 'Paseo mascota'
                              : 'Pet walk'
                          : lang!
                              ? 'Viaje mascota'
                              : 'Pet travel',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: PhotoCarousel(imageUrls: imageUrls),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(rating > 0 ? Icons.star : Icons.star_border,
                              color: Colors.amber),
                          Icon(rating > 1 ? Icons.star : Icons.star_border,
                              color: Colors.amber),
                          Icon(rating > 2 ? Icons.star : Icons.star_border,
                              color: Colors.amber),
                          Icon(rating > 3 ? Icons.star : Icons.star_border,
                              color: Colors.amber),
                          Icon(rating > 4 ? Icons.star : Icons.star_border,
                              color: Colors.amber),
                          const SizedBox(width: 8.0),
                          Text("$rating/5"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              showCommentsDialog(context, commentsPets, 'walks',
                                  widget.id, false);
                            },
                            child: Text(
                              lang! ? "Comentarios" : "Comments",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 90,
                    child: FutureBuilder<List<String>>(
                      future: _array(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: SpinKitSpinningLines(
                                  color: Color.fromRGBO(169, 200, 149, 1),
                                  size: 50.0));
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(lang!
                                  ? 'Error: ${snapshot.error}'
                                  : 'Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(lang!
                                  ? 'No hay información de mascotas'
                                  : 'No pets fetching info'));
                        } else {
                          List<String> ids = snapshot.data!;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: ids.length,
                            itemBuilder: (context, index) {
                              var id = ids[index];
                              var petInfo = showData[id] ?? {};
                              var petInfos = showDatas[id] ?? {};

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    children: [
                                      GestureDetector(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage:
                                              petInfo['imageUrl'] != null
                                                  ? NetworkImage(
                                                      petInfo['imageUrl'])
                                                  : null,
                                        ),
                                        onTap: () {
                                          List<double> ratings =
                                              (petInfos['rating']
                                                      as List<dynamic>)
                                                  .map((e) => e is int
                                                      ? e.toDouble()
                                                      : e as double)
                                                  .toList();
                                          double rating = ratings.isNotEmpty
                                              ? (ratings
                                                      .reduce((a, b) => a + b) /
                                                  ratings.length)
                                              : 0.0;
                                          updateInfoCarrousel(
                                            petInfos['imageUrls'] ?? {},
                                            petInfos['comments'] ?? {},
                                            rating,
                                            petInfos['name'] ??
                                                (lang!
                                                    ? 'Desconocido'
                                                    : 'Unknown'),
                                          );
                                        },
                                      ),
                                      const EmptyBox(h: 5),
                                      Text(petInfos['name'] ??
                                          (lang! ? 'Sin nombre' : 'No name')),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  Column(
                    children: [
                      Center(
                          child: Text(lang!
                              ? "Domicilio: ${widget.place}"
                              : "Address: ${widget.place}")),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(lang! ? "Pago" : "Payment"),
                              Row(
                                children: [
                                  Icon(
                                    widget.payMethod == 'Efectivo'
                                        ? Icons.attach_money_outlined
                                        : Icons.credit_card_sharp,
                                    size: 20,
                                  ),
                                  Text(widget.price.toString()),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(lang!
                                  ? "Pasear con más mascotas"
                                  : "Walk with more pets"),
                              Icon(
                                widget.walkWFriends == 'Si'
                                    ? Icons.check
                                    : Icons.cancel_outlined,
                                size: 20,
                              )
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Center(
                        child: Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  child: widget.timeWalking != ''
                                      ? Text(lang!
                                          ? "Tiempo de paseo: ${widget.timeWalking}"
                                          : "Walking time: ${widget.timeWalking}")
                                      : OutlinedButton(
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewPlaceMap(
                                                        position: LatLng(
                                                            widget
                                                                .travelToPosition
                                                                .latitude,
                                                            widget
                                                                .travelToPosition
                                                                .longitude),
                                                        lang: lang!),
                                              )),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 196, 189, 240),
                                            side: const BorderSide(
                                                color: Color.fromRGBO(
                                                    250, 244, 229, 1),
                                                width: 2),
                                          ),
                                          child: Text(
                                            lang!
                                                ? 'Ubicación de destino'
                                                : 'Destination location',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              await newPreHistory(widget.id, widget.ownerEmail,
                                  email, widget.idBusiness);
                              String phone =
                                  await getUserPhone(widget.ownerEmail);
                              String message = lang!
                                  ? 'PET WALKS Estatus, Usted recibio una solicitud de paseo\n Te invitamos a revisarla y aceptar o denegar al usuario!'
                                  : 'PET WALKS Status, You received a walk request\nWe invite you to review it and accept or deny the user!';
                              twilioService.sendSms(phone, message);

                              setState(() {
                                _isLoading = false;
                              });
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: customOutlinedButtonStyle(),
                            child: _isLoading
                                ? const SpinKitSpinningLines(
                                    color: Color.fromRGBO(169, 200, 149, 1),
                                    size: 50.0)
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Icon(
                                        Icons.flight,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        lang!
                                            ? "Solicitar viaje"
                                            : "Request walk",
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDescriptionDialog(
                                  context, widget.description);
                            },
                            child: Text(
                              lang! ? 'Descripción' : 'Description',
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  void showDescriptionDialog(BuildContext context, String description) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      lang! ? 'Descripción:' : 'Description:',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
