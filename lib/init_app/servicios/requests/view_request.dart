import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/call_comments.dart';
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

  @override
  void initState() {
    super.initState();
    _refreshData();
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
      body: Column(
        children: [
          Stack(
            children: [
              const titleW(title: 'Informacion '),
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
                      const Text(
                        'Regresar',
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  )),
              Positioned(
                  left: 310,
                  top: 70,
                  child: IconButton(
                      onPressed: () => _refreshData,
                      icon: const Column(
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 30,
                            color: Colors.black,
                          ),
                          Text('Actualizar')
                        ],
                      )))
            ],
          ),
          const Divider(),
          Flexible(
            fit: FlexFit.loose,
            child: FutureBuilder<Map<String, dynamic>>(
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
                        Text('Fecha y hora: ${info['startDate'].toString()}',
                            style: _textStyle),
                        Row(
                          children: [
                            const Icon(Icons.price_change),
                            Text(info['price'].toString(), style: _textStyle),
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
                              child: Text('Error: ${petsSnapshot.error}'));
                        } else if (!petsSnapshot.hasData ||
                            petsSnapshot.data!.isEmpty) {
                          return const Center(child: Text('No pets selected'));
                        }

                        final pets = petsSnapshot.data!;
                        print('info[selectedPets]: $pets');

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
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
                                          : const Icon(Icons.pets, size: 40),
                                    ),
                                  ),
                                  Text(
                                    pet['name'] ?? 'No name',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
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

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Paseador:', style: _textStyle),
                              Text('Nombre: ${info['name'] ?? ''}',
                                  style: _textStyle),
                              Text('Telefono: ${info['phone'] ?? ''}',
                                  style: _textStyle),
                              Text('Ruta: ', style: _textStyle),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => toastF('rate user'),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        info['rating'] > 0
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 1
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 2
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 3
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 4
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                  ],
                                ),
                                const SizedBox(width: 8.0),
                                Text('${info['rating'].toString()}/5',
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
                              );
                            },
                            child: const Text(
                              "Comentarios",
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
                          toastF('Denunciar');
                        },
                        icon: const Column(
                          children: [
                            Icon(
                              Icons.report_problem,
                              color: Colors.black,
                            ),
                            Text(
                              'Denunciar',
                            )
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error', style: _textStyle);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data', style: _textStyle);
              }
              final info = snapshot.data!;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text('Dueño:', style: _textStyle),
                            const SizedBox(
                              height: 5,
                            ),
                            Text('Nombre: ${info['name'] ?? ''}',
                                style: _textStyle),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text('Telefono: ${info['phone'] ?? ''}',
                                style: _textStyle),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => toastF('rate user'),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        info['rating'] > 0
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 1
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 2
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 3
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                    Icon(
                                        info['rating'] > 4
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20),
                                  ],
                                ),
                                const SizedBox(width: 8.0),
                                Text('${info['rating'].toString()}/5',
                                    style: _ratingStyle),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showCommentsDialog(context,
                                  info['comments'] ?? [], 'users', idOwner!);
                            },
                            child: const Text(
                              "Comentarios",
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          toastF('Denunciar');
                        },
                        icon: const Column(
                          children: [
                            Icon(Icons.report_problem, color: Colors.black),
                            Text('Denunciar')
                          ],
                        ),
                      ),
                    ),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error', style: _textStyle);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No data', style: _textStyle);
                }
                final info = snapshot.data!;

                return Container();
              },
            ),
        ],
      ),
    );
  }
}
