import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/toast.dart';

class EndWalkManagement extends StatefulWidget {
  const EndWalkManagement({super.key});

  @override
  State<EndWalkManagement> createState() => _EndWalkManagementState();
}

class _EndWalkManagementState extends State<EndWalkManagement> {
  String? email;
  Map<String, bool> _loadingStates = {};
  List<DocumentSnapshot> _pendingRequests = [];

  @override
  void initState() {
    _fetchEmail();
    super.initState();
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
    final pendingRequests = await fetchPendingRequestEnd(email!);
    if (mounted) {
      setState(() {
        _pendingRequests = pendingRequests;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (email == null) {
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
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final walkerDoc = snapshot.data!;
            final profilePhoto = walkerDoc['profilePhoto'] ?? '';
            final rating = walkerDoc['rating'].toInt();
            final name = walkerDoc['name'] ?? 'Desconocido';

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(255, 52, 91, 146).withOpacity(0.7),
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
                        Text('Terminar viaje con: $name',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                        Row(
                          children: [
                            CircleAvatar(
                                backgroundImage: profilePhoto.isEmpty
                                    ? null
                                    : NetworkImage(profilePhoto)),
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
                                    Map<String, dynamic> manageEndWalkInfo =
                                        await manageEndWalk(requestId);
                                    bool owner =
                                        manageEndWalkInfo['emailOwner'] ==
                                            email;

                                    if (owner) {
                                      updateOwner(true, requestId, false);
                                      await Future.delayed(
                                          const Duration(seconds: 10));
                                      bool status = await getWalkerStatus(
                                          requestId, false);
                                      if (status) {
                                        updateHistory(
                                            manageEndWalkInfo['idHistory'],
                                            'done');

                                        toastF('walk finished');
                                        await deleteStartHistory(
                                            requestId, false);
                                        setState(() {
                                          _fetchPendingRequests();
                                        });
                                      } else {
                                        updateOwner(false, requestId, false);
                                        toastF('both users need to be ready');
                                      }
                                    } else {
                                      updateWalker(true, requestId, false);
                                      await Future.delayed(
                                          const Duration(seconds: 10));
                                      if (await getOwnerStatus(
                                          requestId, false)) {
                                        toastF('walk started');
                                      } else {
                                        updateWalker(false, requestId, false);
                                        toastF('both users need to be ready');
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
                              : const Text('Terminar',
                                  style: TextStyle(color: Colors.white)),
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
