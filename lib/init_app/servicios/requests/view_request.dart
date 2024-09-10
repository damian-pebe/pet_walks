import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/comments_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  Future<void> _initializeFutures() async {
    setState(() {
      _refreshData();
    });
  }

  void _refreshData() async {
    String idOwner = await findMatchingUserId(widget.emailOwner);
    String idWalker = await findMatchingUserId(widget.emailWalker);
    setState(() {
      _futureOwnerInfo = getInfoCollectionWithId(idOwner, 'users');
      _futureWalkerInfo = getInfoCollectionWithId(idWalker, 'users');
      _futureBusinessInfo =
          getInfoCollectionWithId(widget.idBusiness, 'business');
      _futureWalkInfo = getInfoCollectionWithId(widget.idWalk, 'walks');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      body: Container(
        color: Colors.brown,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                  future: _futureWalkInfo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No data');
                    }
                    final info = snapshot.data!;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fecha y hora: ${info['startDate']}'),
                            Row(
                              children: [
                                const Icon(Icons.price_change),
                                Text(info['price'].toString()),
                              ],
                            )
                          ],
                        ),
                        ListView()
                      ],
                    );
                  }),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                  future: _futureWalkerInfo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No data');
                    }
                    final info = snapshot.data!;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                const Text('Paseador:'),
                                Text('Nombre: ${info['name'] ?? ''}'),
                                Text('Email: ${info['email'] ?? ''}'),
                                Text('Telefono: ${info['phone'] ?? ''}'),
                                const Text('Ruta: ')
                              ],
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
                                              size: 13),
                                          Icon(
                                              info['rating'] > 1
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                          Icon(
                                              info['rating'] > 2
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                          Icon(
                                              info['rating'] > 3
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                          Icon(
                                              info['rating'] > 4
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                        ],
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        '${info['rating'].toString()}/5',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                CommentsDialog(comments: info['comments'] ?? [])
                              ],
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              onPressed: () {
                                toastF('Denunciar');
                              },
                              icon: const Column(
                                children: [
                                  Icon(Icons.report_problem),
                                  Text('Denunciar')
                                ],
                              )),
                        )
                      ],
                    );
                  }),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                  future: _futureOwnerInfo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No data');
                    }
                    final info = snapshot.data!;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                const Text('Dueño:'),
                                Text('Nombre: ${info['name'] ?? ''}'),
                                Text('Email: ${info['email'] ?? ''}'),
                                Text('Telefono: ${info['phone'] ?? ''}'),
                              ],
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
                                              size: 13),
                                          Icon(
                                              info['rating'] > 1
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                          Icon(
                                              info['rating'] > 2
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                          Icon(
                                              info['rating'] > 3
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                          Icon(
                                              info['rating'] > 4
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 13),
                                        ],
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        '${info['rating'].toString()}/5',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                CommentsDialog(comments: info['comments'] ?? [])
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Image.network(''),
                            IconButton(
                                onPressed: () {
                                  toastF('Denunciar');
                                },
                                icon: const Column(
                                  children: [
                                    Icon(Icons.report_problem),
                                    Text('Denunciar')
                                  ],
                                ))
                          ],
                        )
                      ],
                    );
                  }),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                  future: _futureBusinessInfo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No data');
                    }
                    final info = snapshot.data!;

                    return Container();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
