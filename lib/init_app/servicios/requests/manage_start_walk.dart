import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/toast.dart';

class StartWalkManagement extends StatefulWidget {
  const StartWalkManagement({super.key});

  @override
  State<StartWalkManagement> createState() => _StartWalkManagementState();
}

class _StartWalkManagementState extends State<StartWalkManagement> {
  String? email;
  Map<String, bool> _loadingStates = {};
  List<DocumentSnapshot> _pendingRequests = [];
  bool? lang;

  @override
  void initState() {
    super.initState();
    _fetchEmail();
    _getLanguage();
  }

  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  Future<void> _fetchEmail() async {
    final fetchedEmail = await fetchUserEmail();
    setState(() {
      email = fetchedEmail;
    });
    if (email != null) {
      _fetchPendingRequests();
    }
  }

  Future<void> _fetchPendingRequests() async {
    final pendingRequests = await fetchPendingRequestStart(email!);
    if (mounted) {
      setState(() {
        _pendingRequests = pendingRequests;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (email == null || lang == null) {
      return const Center(
          child: SpinKitSpinningLines(color: Colors.blue, size: 50.0));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final doc = _pendingRequests[index];
        final requestId = doc.id;
        final emailWalker = doc['emailWalker'];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where("email", isEqualTo: emailWalker)
              .limit(1)
              .get()
              .then((snapshot) => snapshot.docs.first),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            } else if (snapshot.hasError) {
              return Text(lang!
                  ? 'Error: ${snapshot.error}'
                  : 'Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final walkerDoc = snapshot.data!;
            final profilePhoto = walkerDoc['profilePhoto'] ?? '';
            List<double> ratings = (walkerDoc['rating'] as List<dynamic>)
                .map((e) => e is int ? e.toDouble() : e as double)
                .toList();
            double rating = ratings.isNotEmpty
                ? (ratings.reduce((a, b) => a + b) / ratings.length)
                : 0.0;
            final name = walkerDoc['name'] ?? '';

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 153, 80, 190)
                        .withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang!
                              ? 'Iniciar viaje con: $name'
                              : 'Start trip with: $name',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: profilePhoto.isEmpty
                                  ? null
                                  : NetworkImage(profilePhoto),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                Icon(
                                    rating > 0 ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 13),
                                Icon(
                                    rating > 1 ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 13),
                                Icon(
                                    rating > 2 ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 13),
                                Icon(
                                    rating > 3 ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 13),
                                Icon(
                                    rating > 4 ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 13),
                              ],
                            ),
                            const SizedBox(width: 8.0),
                            Text('$rating/5',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: _loadingStates[requestId] == true
                              ? null
                              : () async {
                                  setState(() {
                                    _loadingStates[requestId] = true;
                                  });
                                  try {
                                    Map<String, dynamic> manageStartWalkInfo =
                                        await manageStartWalk(requestId);
                                    bool owner =
                                        manageStartWalkInfo['emailOwner'] ==
                                            email;

                                    if (owner) {
                                      updateOwner(true, requestId, true);
                                      await Future.delayed(
                                          const Duration(seconds: 10));
                                      bool status = await getWalkerStatus(
                                          requestId, true);
                                      if (status) {
                                        await newEndWalk(
                                            manageStartWalkInfo['idWalk'],
                                            manageStartWalkInfo['emailOwner'],
                                            manageStartWalkInfo['emailWalker'],
                                            manageStartWalkInfo['idBusiness'],
                                            manageStartWalkInfo['idHistory']);
                                        updateHistory(
                                            manageStartWalkInfo['idHistory'],
                                            'walking',
                                            DateTime.now(),
                                            true); //true because its start
                                        toastF(lang!
                                            ? 'Viaje iniciado'
                                            : 'Walk started');
                                        await deleteStartHistory(
                                            requestId, true);
                                        setState(() {
                                          _fetchPendingRequests();
                                        });
                                      } else {
                                        updateOwner(false, requestId, true);
                                        toastF(lang!
                                            ? 'Ambos usuarios deben estar listos'
                                            : 'Both users need to be ready');
                                      }
                                    } else {
                                      updateWalker(true, requestId, true);
                                      await Future.delayed(
                                          const Duration(seconds: 10));
                                      if (await getOwnerStatus(
                                          requestId, true)) {
                                        toastF(lang!
                                            ? 'Viaje iniciado'
                                            : 'Walk started');
                                      } else {
                                        updateWalker(false, requestId, true);
                                        toastF(lang!
                                            ? 'Ambos usuarios deben estar listos'
                                            : 'Both users need to be ready');
                                      }
                                    }
                                  } finally {
                                    setState(() {
                                      _loadingStates[requestId] = false;
                                    });
                                  }
                                },
                          child: _loadingStates[requestId] == true
                              ? const SpinKitFadingCube(
                                  color: Colors.white, size: 20.0)
                              : Text(
                                  lang! ? 'Iniciar' : 'Start',
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
