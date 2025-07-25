// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/init_app/servicios/chat.dart';
import 'package:petwalks_app/init_app/servicios/markers_details/place_view.dart';
import 'package:petwalks_app/init_app/servicios/reports.dart';
import 'package:petwalks_app/init_app/servicios/view_active_route.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/services/stripe_services.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/widgets/call_comments.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/rate_dialog.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class ViewRequest extends StatefulWidget {
  final String emailOwner;
  final String emailWalker;
  final String idBusiness;
  final String idWalk;
  final String idHistory;
  final String status;
  final Timestamp? timeStart;
  const ViewRequest(
      {required this.idBusiness,
      required this.emailOwner,
      required this.idWalk,
      required this.emailWalker,
      required this.idHistory,
      required this.status,
      required this.timeStart,
      super.key});

  @override
  State<ViewRequest> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  ValueNotifier<map.LatLng?> positionNotifier =
      ValueNotifier<map.LatLng?>(null);
  ValueNotifier<map.LatLng?> businessNotifier =
      ValueNotifier<map.LatLng?>(null);

  map.LatLng? position;
  map.LatLng? business;
  void _getLatLngFromAddressWalk(String address) async {
    try {
      position = await getLatLngFromAddress(address);
      positionNotifier.value = position;
    } catch (e) {
      positionNotifier.value = const map.LatLng(20.6240472, -103.3504135);
    }
  }

  void _getLatLngFromAddressBusiness(String address) async {
    try {
      business = await getLatLngFromAddress(address);
      businessNotifier.value = business;
    } catch (e) {
      businessNotifier.value = const map.LatLng(20.6240472, -103.3504135);
    }
  }

  int? amount;

  Future<Map<String, dynamic>>? _futureOwnerInfo;
  Future<Map<String, dynamic>>? _futureWalkerInfo;
  Future<Map<String, dynamic>>? _futureBusinessInfo;
  Future<Map<String, dynamic>>? _futureWalkInfo;

  final TextStyle _textStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );
  final TextStyle _titleStyle = const TextStyle(
    fontSize: 18,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  final TextStyle _ratingStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  String? payType;
  String? email;
  initEmail() async {
    email = await fetchUserEmail();
  }

  DateTime thief = DateTime.now().add(const Duration(hours: 1));
  Timestamp identifierNow = Timestamp.now();
  @override
  void initState() {
    super.initState();
    _refreshData();
    initEmail();
    _getLanguage();
    if (widget.timeStart != null) {
      thief = widget.timeStart!.toDate().add(const Duration(minutes: 60));
    }
  }

  String? reported;
  String? sender;
  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});

    String temp = await fetchUserEmail();
    temp == widget.emailOwner
        ? reported = widget.emailWalker
        : reported = widget.emailWalker;
    temp == widget.emailOwner
        ? sender = widget.emailOwner
        : sender = widget.emailOwner;
  }

  String? idOwner;
  String? idWalker;
  void _refreshData() async {
    idOwner = await findMatchingUserId(widget.emailOwner);
    idWalker = await findMatchingUserId(widget.emailWalker);

    _futureOwnerInfo = getInfoCollectionWithId(idOwner!, 'users');
    _futureWalkerInfo = getInfoCollectionWithId(idWalker!, 'users');
    _futureBusinessInfo =
        getInfoCollectionWithId(widget.idBusiness, 'business');
    _futureWalkInfo = getInfoCollectionWithId(widget.idWalk, 'walks');
    payType = await getPaymentMethod(widget.idHistory);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 163, 114, 96),
      body: lang == null
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
          : Column(
              children: [
                Stack(
                  children: [
                    titleW(
                      title: lang! ? 'Info paseo    ' : 'Walk info    ',
                    ),
                    Positioned(
                        left: 30,
                        top: 70,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios,
                              size: 30, color: Colors.black),
                        )),
                    Positioned(
                        left: 340,
                        top: 70,
                        child: IconButton(
                            onPressed: () async {
                              try {
                                String currentUser = await fetchUserEmail();
                                String? oldChat;

                                if (widget.emailOwner == currentUser) {
                                  oldChat =
                                      await getOldChatId(widget.emailWalker);
                                  if (oldChat == null) {
                                    String idChat =
                                        await newChat(widget.emailWalker);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatView(chatId: idChat),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatView(chatId: oldChat!),
                                      ),
                                    );
                                  }
                                } else {
                                  oldChat =
                                      await getOldChatId(widget.emailOwner);
                                  if (oldChat == null) {
                                    String idChat =
                                        await newChat(widget.emailOwner);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatView(chatId: idChat),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatView(chatId: oldChat!),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                // Handle error but it works so i dont need it now
                              }
                            },
                            icon: const Icon(
                              Icons.chat_rounded,
                              size: 30,
                              color: Colors.black,
                            ))),
                    Positioned(
                        left: 290,
                        top: 70,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Reports(
                                  lang: lang ?? false,
                                  options: const [
                                    'Urgent/Urgente',
                                    'Attack/Agresion',
                                    'Doubt question/Duda sobre robo',
                                    'Incorrect Payments/Pagos Incorrectos'
                                  ],
                                  reported: reported!,
                                  sender: sender!,
                                  priority: 'high',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.report_outlined,
                            size: 30,
                            color: Colors.black,
                          ),
                        ))
                  ],
                ),
                if (identifierNow.toDate().isBefore(thief)) const Divider(),
                if (identifierNow.toDate().isBefore(thief))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        Text(
                            lang!
                                ? 'Si su viaje ya concluyo y no lo termino, puede finalizar, si no es asi, reportelo porfavor.'
                                : 'If your trip has already concluded and you have not finished it, you can end it, if not, report it please.',
                            style: _textStyle),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            OutlinedButton(
                                onPressed: () {},
                                style: customOutlinedButtonStyleGreen(),
                                child: Text(lang! ? 'Forzar fin' : 'Force end',
                                    style: _titleStyle)),
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Reports(
                                        lang: lang ?? false,
                                        options: const [
                                          'Tief/Robo',
                                        ],
                                        reported: reported!,
                                        sender: sender!,
                                        priority: 'high',
                                      ),
                                    ),
                                  );
                                },
                                style: customOutlinedButtonStyleGreen(),
                                child: Text(
                                    lang!
                                        ? 'Reportar por robo'
                                        : 'Report thief',
                                    style: _titleStyle)),
                          ],
                        )
                      ],
                    ),
                  ),
                const SizedBox(height: 5),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        FutureBuilder<Map<String, dynamic>>(
                          future: _futureWalkInfo,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: SpinKitSpinningLines(
                                      color: Color.fromRGBO(169, 200, 149, 1),
                                      size: 50.0));
                            } else if (snapshot.hasError) {
                              return Text('Error', style: _textStyle);
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text('No data', style: _textStyle);
                            }
                            final info = snapshot.data!;
                            amount = info['price'];
                            _getLatLngFromAddressWalk(info['address']);

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                            (widget.timeStart == null ||
                                                    widget.timeStart
                                                        .toString()
                                                        .isEmpty)
                                                ? (lang!
                                                    ? 'Esperando'
                                                    : 'Awaiting')
                                                : (widget.timeStart
                                                        is Timestamp)
                                                    ? () {
                                                        return DateFormat(
                                                                'd/M/y h:mm a')
                                                            .format((widget
                                                                        .timeStart
                                                                    as Timestamp)
                                                                .toDate());
                                                      }()
                                                    : DateTime.tryParse(widget
                                                                .timeStart
                                                                .toString()) !=
                                                            null
                                                        ? () {
                                                            return DateFormat(
                                                                    'd/M/y h:mm a')
                                                                .format(DateTime
                                                                    .parse(widget
                                                                        .timeStart
                                                                        .toString()));
                                                          }()
                                                        : () {
                                                            return widget
                                                                .timeStart
                                                                .toString();
                                                          }(),
                                            style: _textStyle),
                                        Row(
                                          children: [
                                            const Icon(Icons.price_change),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(amount.toString(),
                                                style: _textStyle),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      (lang! ? 'Estatus: ' : 'Status: ') +
                                          (widget.status == 'awaiting'
                                              ? (lang!
                                                  ? 'Esperando'
                                                  : 'Awaiting')
                                              : widget.status == 'walking'
                                                  ? (lang!
                                                      ? 'Paseando'
                                                      : 'Walking')
                                                  : (lang!
                                                      ? 'Finalizado'
                                                      : 'Done')),
                                      style: _titleStyle,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                FutureBuilder<Set<Map<String, dynamic>>>(
                                  future: fetchImageNamePet(List<String>.from(
                                      info['selectedPets'] ?? [])),
                                  builder: (context, petsSnapshot) {
                                    if (petsSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: SpinKitSpinningLines(
                                              color: Color.fromRGBO(
                                                  169, 200, 149, 1),
                                              size: 50.0));
                                    } else if (petsSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${petsSnapshot.error}'));
                                    } else if (!petsSnapshot.hasData ||
                                        petsSnapshot.data!.isEmpty) {
                                      return Center(
                                          child: Text(
                                        lang!
                                            ? 'No se encontraron mascotas'
                                            : 'No pets found',
                                      ));
                                    }

                                    final pets = petsSnapshot.data!;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: pets.map((pet) {
                                          return Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: ClipOval(
                                                  child: pet['imageUrl'] != null
                                                      ? Image.network(
                                                          pet['imageUrl'],
                                                          fit: BoxFit.cover,
                                                          width: 60,
                                                          height: 60,
                                                        )
                                                      : const Icon(Icons.pets,
                                                          size: 40),
                                                ),
                                              ),
                                              Text(
                                                pet['name'] ?? 'No name',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              )
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    lang!
                                        ? 'Domicilio: ${info['address'] ?? ''}'
                                        : 'Address: ${info['address'] ?? ''}',
                                    style: _textStyle),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ValueListenableBuilder<map.LatLng?>(
                                      valueListenable: positionNotifier,
                                      builder: (context, position, child) {
                                        if (position != null) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                                height: 190,
                                                width: 390,
                                                child: FlutterMap(
                                                  options: MapOptions(
                                                    initialCenter:
                                                        latLng.LatLng(
                                                            position.latitude,
                                                            position.longitude),
                                                    initialZoom: 17,
                                                  ),
                                                  children: [
                                                    TileLayer(
                                                      urlTemplate: urlMap,
                                                    ),
                                                    MarkerLayer(
                                                      markers: [
                                                        Marker(
                                                            point: latLng.LatLng(
                                                                position
                                                                    .latitude,
                                                                position
                                                                    .longitude),
                                                            width: 80,
                                                            height: 80,
                                                            child: TextButton(
                                                              child:
                                                                  Image.asset(
                                                                userMarker,
                                                                width: 80,
                                                                height: 80,
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => ViewPlaceMap(
                                                                            position:
                                                                                map.LatLng(position.latitude, position.longitude),
                                                                            lang: lang!),
                                                                      )),
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          );
                                        } else {
                                          return const Center(
                                              child: SpinKitSpinningLines(
                                                  color: Color.fromRGBO(
                                                      169, 200, 149, 1),
                                                  size: 50.0));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const Divider(),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _futureWalkerInfo,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: SpinKitSpinningLines(
                                      color: Color.fromRGBO(169, 200, 149, 1),
                                      size: 50.0));
                            } else if (snapshot.hasError) {
                              return Text('Error', style: _textStyle);
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text('No data', style: _textStyle);
                            }
                            final info = snapshot.data!;
                            List<double> ratings =
                                (info['rating'] as List<dynamic>)
                                    .map((e) =>
                                        e is int ? e.toDouble() : e as double)
                                    .toList();
                            double rating = ratings.isNotEmpty
                                ? (ratings.reduce((a, b) => a + b) /
                                    ratings.length)
                                : 0.0;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                lang!
                                                    ? '  Paseador:'
                                                    : '  Walker:',
                                                style: _titleStyle),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                lang!
                                                    ? 'Nombre: ${info['name'] ?? ''}'
                                                    : 'Name: ${info['name'] ?? ''}',
                                                style: _textStyle),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                lang!
                                                    ? 'Telefono: ${info['phone'] ?? ''}'
                                                    : 'Phone: ${info['phone'] ?? ''}',
                                                style: _textStyle),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(lang! ? 'Ruta: ' : 'Route: ',
                                                style: _textStyle),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (email != widget.emailWalker) {
                                              toastF(lang!
                                                  ? 'Calificar usuario'
                                                  : 'Rate user');
                                              showRatingPopup(context, rating,
                                                  (newRating) {
                                                setState(() {
                                                  toastF(lang!
                                                      ? 'Usuario calificado: $newRating'
                                                      : 'User rated: $newRating');
                                                });
                                              }, 'users', idWalker!);
                                            } else {
                                              toastF(lang!
                                                  ? 'Este eres tú'
                                                  : 'This is you');
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                      rating > 0
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 1
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 2
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 3
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 4
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                ],
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                  '${(rating).round().toString()}/5',
                                                  style: _ratingStyle),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            showCommentsDialog(
                                                context,
                                                info['comments'] ?? [],
                                                'users',
                                                idWalker!,
                                                email != widget.emailWalker
                                                    ? true
                                                    : false);
                                          },
                                          child: Text(
                                            lang! ? 'Comentarios' : 'Comments',
                                            style: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 18,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    widget.status == 'awaiting'
                                        ? Text(
                                            lang!
                                                ? 'Esperando inicio'
                                                : 'Awaiting',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          )
                                        : TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RouteMap(
                                                    idWalk: widget.idHistory,
                                                    lang: lang!,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16.0,
                                                      horizontal: 32.0),
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      169,
                                                      200,
                                                      149,
                                                      1), // Background color
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30.0), // Rounded corners
                                              ),
                                              elevation:
                                                  5.0, // Adds a shadow to make it pop
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  lang!
                                                      ? 'Ver ruta de paseo'
                                                      : 'View walk route',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors
                                                        .black, // Text color
                                                    fontWeight: FontWeight
                                                        .bold, // Bold text
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                const Icon(Icons.pets,
                                                    color: Colors.black)
                                              ],
                                            ),
                                          )
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                        const Divider(),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _futureOwnerInfo,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: SpinKitSpinningLines(
                                      color: Color.fromRGBO(169, 200, 149, 1),
                                      size: 50.0));
                            } else if (snapshot.hasError) {
                              return Text('Error', style: _textStyle);
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text('No data', style: _textStyle);
                            }
                            final info = snapshot.data!;
                            List<double> ratings =
                                (info['rating'] as List<dynamic>)
                                    .map((e) =>
                                        e is int ? e.toDouble() : e as double)
                                    .toList();
                            double rating = ratings.isNotEmpty
                                ? (ratings.reduce((a, b) => a + b) /
                                    ratings.length)
                                : 0.0;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                lang! ? '  Dueño:' : '  Owner:',
                                                style: _titleStyle),
                                            const SizedBox(height: 5),
                                            Text(
                                                lang!
                                                    ? 'Nombre: ${info['name'] ?? ''}'
                                                    : 'Name: ${info['name'] ?? ''}',
                                                style: _textStyle),
                                            const SizedBox(height: 5),
                                            Text(
                                                lang!
                                                    ? 'Teléfono: ${info['phone'] ?? ''}'
                                                    : 'Phone: ${info['phone'] ?? ''}',
                                                style: _textStyle),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (email != widget.emailOwner) {
                                              toastF(lang!
                                                  ? 'Calificar usuario'
                                                  : 'Rate user');
                                              showRatingPopup(context, rating,
                                                  (newRating) {
                                                setState(() {
                                                  toastF(lang!
                                                      ? 'Usuario calificado: $newRating'
                                                      : 'User rated: $newRating');
                                                });
                                              }, 'users', idOwner!);
                                            } else {
                                              toastF(lang!
                                                  ? 'Este eres tú'
                                                  : 'This is you');
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                      rating > 0
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 1
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 2
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 3
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                  Icon(
                                                      rating > 4
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20),
                                                ],
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                  '${(rating).round().toString()}/5',
                                                  style: _ratingStyle),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            showCommentsDialog(
                                                context,
                                                info['comments'] ?? [],
                                                'users',
                                                idOwner!,
                                                email != widget.emailOwner
                                                    ? true
                                                    : false);
                                          },
                                          child: Text(
                                            lang! ? 'Comentarios' : 'Comments',
                                            style: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 18,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        if (widget.idBusiness.isNotEmpty) const Divider(),
                        if (widget.idBusiness.isNotEmpty)
                          FutureBuilder<Map<String, dynamic>>(
                            future: _futureBusinessInfo,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: SpinKitSpinningLines(
                                        color: Color.fromRGBO(169, 200, 149, 1),
                                        size: 50.0));
                              } else if (snapshot.hasError) {
                                return Text('Error', style: _textStyle);
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Text('No data', style: _textStyle);
                              }
                              final info = snapshot.data!;
                              List<double> ratings =
                                  (info['rating'] as List<dynamic>)
                                      .map((e) =>
                                          e is int ? e.toDouble() : e as double)
                                      .toList();
                              double rating = ratings.isNotEmpty
                                  ? (ratings.reduce((a, b) => a + b) /
                                      ratings.length)
                                  : 0.0;

                              _getLatLngFromAddressBusiness(info['address']);

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  lang!
                                                      ? '  Empresa:'
                                                      : '  Company:',
                                                  style: _titleStyle),
                                              const SizedBox(height: 5),
                                              Text(
                                                  lang!
                                                      ? 'Nombre: ${info['name'] ?? ''}'
                                                      : 'Name: ${info['name'] ?? ''}',
                                                  style: _textStyle),
                                              const SizedBox(height: 5),
                                              Text(
                                                  lang!
                                                      ? 'Teléfono: ${info['phone'] ?? ''}'
                                                      : 'Phone: ${info['phone'] ?? ''}',
                                                  style: _textStyle),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (email != widget.emailWalker &&
                                                  email != widget.emailOwner) {
                                                toastF(lang!
                                                    ? 'Calificar usuario'
                                                    : 'Rate user');
                                                showRatingPopup(context, rating,
                                                    (newRating) {
                                                  setState(() {
                                                    toastF(lang!
                                                        ? 'Usuario calificado: $newRating'
                                                        : 'User rated: $newRating');
                                                  });
                                                }, 'business',
                                                    widget.idBusiness);
                                              } else {
                                                toastF(lang!
                                                    ? 'Este eres tú'
                                                    : 'This is you');
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                        rating > 0
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 20),
                                                    Icon(
                                                        rating > 1
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 20),
                                                    Icon(
                                                        rating > 2
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 20),
                                                    Icon(
                                                        rating > 3
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 20),
                                                    Icon(
                                                        rating > 4
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 20),
                                                  ],
                                                ),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                    '${(rating).round().toString()}/5',
                                                    style: _ratingStyle),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              showCommentsDialog(
                                                  context,
                                                  info['comments'] ?? [],
                                                  'business',
                                                  widget.idBusiness,
                                                  email != widget.emailWalker &&
                                                          email !=
                                                              widget.emailOwner
                                                      ? true
                                                      : false);
                                            },
                                            child: Text(
                                              lang!
                                                  ? 'Comentarios'
                                                  : 'Comments',
                                              style: const TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontSize: 18,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                      lang!
                                          ? 'Categoria: ${info['category'] ?? ''}'
                                          : 'Category: ${info['category'] ?? ''}',
                                      style: _textStyle),
                                  const SizedBox(height: 5),
                                  Text(
                                      lang!
                                          ? 'Domicilio:: ${info['address'] ?? ''}'
                                          : 'Address: ${info['address'] ?? ''}',
                                      style: _textStyle),
                                  const SizedBox(height: 5),
                                  ValueListenableBuilder<map.LatLng?>(
                                    valueListenable: businessNotifier,
                                    builder: (context, business, child) {
                                      if (business != null) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                              height: 190,
                                              width: 390,
                                              child: FlutterMap(
                                                options: MapOptions(
                                                  initialCenter: latLng.LatLng(
                                                      business.latitude,
                                                      business.longitude),
                                                  initialZoom: 17,
                                                ),
                                                children: [
                                                  TileLayer(
                                                    urlTemplate: urlMap,
                                                  ),
                                                  MarkerLayer(
                                                    markers: [
                                                      Marker(
                                                          point: latLng.LatLng(
                                                              business.latitude,
                                                              business
                                                                  .longitude),
                                                          width: 80,
                                                          height: 80,
                                                          child: TextButton(
                                                            child: Image.asset(
                                                              userMarker,
                                                              width: 80,
                                                              height: 80,
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => ViewPlaceMap(
                                                                          position: map.LatLng(
                                                                              business.latitude,
                                                                              business.longitude),
                                                                          lang: lang!),
                                                                    )),
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                        );
                                      } else {
                                        return const Center(
                                            child: SpinKitSpinningLines(
                                                color: Color.fromRGBO(
                                                    169, 200, 149, 1),
                                                size: 50.0));
                                      }
                                    },
                                  )
                                ],
                              );
                            },
                          ),
                        if (widget.idBusiness.isNotEmpty) const Divider(),
                      ],
                    ),
                  ),
                ),
                if (payType != null) const Divider(),
                payType == null
                    ? const SizedBox.shrink()
                    : payType == 'awaiting'
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: OutlinedButton(
                              onPressed: () {
                                StripeService.instance.makePayment(
                                    context, amount!, widget.idHistory);
                              },
                              style: customOutlinedButtonStyleGreen(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.credit_card,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 30),
                                  Text(
                                    lang! ? 'Pagar paseo' : 'Pay for this walk',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              //payType == done
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 24.0),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(169, 200, 149, 1),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    lang!
                                        ? 'Pago realizado'
                                        : 'Payment already made',
                                    style: const TextStyle(
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
                                  const Icon(
                                    Icons.payment,
                                    size: 25,
                                    color: Colors.black,
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
