import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/call_comments.dart';
import 'package:petwalks_app/widgets/rate_dialog.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class ViewRequest extends StatefulWidget {
  final String emailOwner;
  final String emailWalker;
  final String idBusiness;
  final String idWalk;
  const ViewRequest(
      {required this.idBusiness,
      required this.emailOwner,
      required this.idWalk,
      required this.emailWalker,
      super.key});

  @override
  State<ViewRequest> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  ValueNotifier<LatLng?> positionNotifier = ValueNotifier<LatLng?>(null);
  ValueNotifier<LatLng?> businessNotifier = ValueNotifier<LatLng?>(null);

  LatLng? position;
  LatLng? business;
  void _getLatLngFromAddressOwner(String address) async {
    position = await getLatLngFromAddress(address);
    positionNotifier.value = position;
  }

  void _getLatLngFromAddressBusiness(String address) async {
    business = await getLatLngFromAddress(address);
    businessNotifier.value = business;
  }

  Future<Map<String, dynamic>>? _futureOwnerInfo;
  Future<Map<String, dynamic>>? _futureWalkerInfo;
  Future<Map<String, dynamic>>? _futureBusinessInfo;
  Future<Map<String, dynamic>>? _futureWalkInfo;

  final TextStyle _textStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  final TextStyle _ratingStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  String? email;
  initEmail() async {
    email = await fetchUserEmail();
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
    initEmail();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 163, 114, 96),
      body: lang == null
          ? null
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      titleW(
                        title: lang! ? 'Info paseo' : 'Walk info',
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
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )),
                      Positioned(
                          left: 310,
                          top: 70,
                          child: IconButton(
                              onPressed: () => _refreshData(),
                              icon: Column(
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    lang! ? 'Actualizar' : 'Refresh',
                                  )
                                ],
                              )))
                    ],
                  ),
                  const Divider(),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _futureWalkInfo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error', style: _textStyle);
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No data', style: _textStyle);
                      }
                      final info = snapshot.data!;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                  lang!
                                      ? 'Fecha y hora: ${info['startDate'].toString()}'
                                      : 'Date & Time: ${info['startDate'].toString()}',
                                  style: _textStyle),
                              Row(
                                children: [
                                  const Icon(Icons.price_change),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(info['price'].toString(),
                                      style: _textStyle),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FutureBuilder<Set<Map<String, dynamic>>>(
                            future: fetchImageNamePet(
                                List<String>.from(info['selectedPets'] ?? [])),
                            builder: (context, petsSnapshot) {
                              if (petsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (petsSnapshot.hasError) {
                                return Center(
                                    child:
                                        Text('Error: ${petsSnapshot.error}'));
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: pets.map((pet) {
                                    return Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.grey[200],
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
                                              fontWeight: FontWeight.bold),
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
                          )
                        ],
                      );
                    },
                  ),
                  const Divider(),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _futureWalkerInfo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error', style: _textStyle);
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No data', style: _textStyle);
                      }
                      final info = snapshot.data!;
                      List<double> ratings = (info['rating'] as List<dynamic>)
                          .map((e) => e is int ? e.toDouble() : e as double)
                          .toList();
                      double rating = ratings.isNotEmpty
                          ? (ratings.reduce((a, b) => a + b) / ratings.length)
                          : 0.0;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(lang! ? 'Paseador:' : 'Walker:',
                                          style: _textStyle),
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
                                        Text('${rating.toString()}/5',
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
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 18,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('This will be the onTimeTracking func',
                                  style: _textStyle),
                              IconButton(
                                onPressed: () {
                                  toastF(
                                    lang! ? 'Denunciar' : 'Report',
                                  );
                                },
                                icon: const Icon(
                                  Icons.report_problem,
                                  color: Colors.black,
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error', style: _textStyle);
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No data', style: _textStyle);
                      }
                      final info = snapshot.data!;
                      List<double> ratings = (info['rating'] as List<dynamic>)
                          .map((e) => e is int ? e.toDouble() : e as double)
                          .toList();
                      double rating = ratings.isNotEmpty
                          ? (ratings.reduce((a, b) => a + b) / ratings.length)
                          : 0.0;

                      _getLatLngFromAddressOwner(info['address']);

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(lang! ? 'Dueño:' : 'Owner:',
                                        style: _textStyle),
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
                                        Text('${rating.toString()}/5',
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
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 18,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ValueListenableBuilder<LatLng?>(
                                valueListenable: positionNotifier,
                                builder: (context, position, child) {
                                  if (position != null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 200,
                                        width: 300,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: position,
                                            zoom: 15,
                                          ),
                                          markers: {
                                            Marker(
                                              markerId:
                                                  const MarkerId('marker'),
                                              position: position,
                                            ),
                                          },
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  toastF(
                                    lang! ? 'Denunciar' : 'Report',
                                  );
                                },
                                icon: const Icon(
                                  Icons.report_problem,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          )
                        ],
                      );
                    },
                  ),
                  const Divider(),
                  if (widget.idBusiness.isNotEmpty)
                    FutureBuilder<Map<String, dynamic>>(
                      future: _futureBusinessInfo,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error', style: _textStyle);
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('No data', style: _textStyle);
                        }
                        final info = snapshot.data!;
                        List<double> ratings = (info['rating'] as List<dynamic>)
                            .map((e) => e is int ? e.toDouble() : e as double)
                            .toList();
                        double rating = ratings.isNotEmpty
                            ? (ratings.reduce((a, b) => a + b) / ratings.length)
                            : 0.0;

                        _getLatLngFromAddressBusiness(info['address']);

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(lang! ? 'Empresa:' : 'Company:',
                                          style: _textStyle),
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
                                          }, 'business', widget.idBusiness);
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
                                          Text('${rating.toString()}/5',
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
                                                    email != widget.emailOwner
                                                ? true
                                                : false);
                                      },
                                      child: Text(
                                        lang! ? 'Comentarios' : 'Comments',
                                        style: TextStyle(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ValueListenableBuilder<LatLng?>(
                                  valueListenable: businessNotifier,
                                  builder: (context, business, child) {
                                    if (business != null) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 200,
                                          width: 300,
                                          child: GoogleMap(
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: business,
                                              zoom: 15,
                                            ),
                                            markers: {
                                              Marker(
                                                markerId: const MarkerId(
                                                    'Get pets here'),
                                                position: business,
                                              ),
                                            },
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                                IconButton(
                                  onPressed: () {
                                    toastF(
                                      lang! ? 'Denunciar' : 'Report',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.report_problem,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  if (widget.idBusiness.isNotEmpty) const Divider(),
                ],
              ),
            ),
    );
  }
}
