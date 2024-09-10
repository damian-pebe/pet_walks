import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/toast.dart';

class PendingRequestsNotifications extends StatefulWidget {
  const PendingRequestsNotifications({super.key});

  @override
  State<PendingRequestsNotifications> createState() =>
      _PendingRequestsNotificationsState();
}

class _PendingRequestsNotificationsState
    extends State<PendingRequestsNotifications> {
  String? email;
  List<Map<String, dynamic>> pendingRequestsData = [];

  @override
  void initState() {
    super.initState();
    _initializeEmail();
  }

  Future<void> _initializeEmail() async {
    email = await fetchUserEmail();
    setState(() {});

    if (email != null) {
      _fetchAndShowNotifications(email!);
    }
  }

  Future<void> _fetchAndShowNotifications(String email) async {
    final pendingRequests = await fetchPendingRequests(email);
    if (pendingRequests.isEmpty) return;

    for (var doc in pendingRequests) {
      String requestId = doc.id;
      String emailWalker = doc['emailWalker'];

      QuerySnapshot walkerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: emailWalker)
          .get();

      if (walkerSnapshot.docs.isNotEmpty) {
        DocumentSnapshot walkerDoc = walkerSnapshot.docs.first;

        String profilePhoto = walkerDoc['profilePhoto'] ?? '';
        int rating = walkerDoc['rating'].toInt();
        String name = walkerDoc['name'] ?? 'Desconocido';

        pendingRequestsData.add({
          'requestId': requestId,
          'profilePhoto': profilePhoto,
          'rating': rating,
          'name': name,
          'doc': doc,
        });
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (email == null) {
      return const CircularProgressIndicator();
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: pendingRequestsData.length,
      itemBuilder: (context, index) {
        final data = pendingRequestsData[index];
        final requestId = data['requestId'];
        final profilePhoto = data['profilePhoto'];
        final rating = data['rating'];
        final name = data['name'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 112, 69, 69).withOpacity(0.7),
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
                    Text('Solicitud de: $name',
                        style: const TextStyle(color: Colors.white)),
                    Row(
                      children: [
                        CircleAvatar(
                            backgroundImage: profilePhoto.isEmpty
                                ? null
                                : NetworkImage(profilePhoto)),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Icon(rating > 0 ? Icons.star : Icons.star_border,
                                color: Colors.amber, size: 13),
                            Icon(rating > 1 ? Icons.star : Icons.star_border,
                                color: Colors.amber, size: 13),
                            Icon(rating > 2 ? Icons.star : Icons.star_border,
                                color: Colors.amber, size: 13),
                            Icon(rating > 3 ? Icons.star : Icons.star_border,
                                color: Colors.amber, size: 13),
                            Icon(rating > 4 ? Icons.star : Icons.star_border,
                                color: Colors.amber, size: 13),
                          ],
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '$rating/5',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: () async {
                          Map<String, dynamic> manageStartWalkInfo =
                              await managePreHistory(requestId);
                          String id = await newHistoryWalk(
                            manageStartWalkInfo['idWalk'],
                            manageStartWalkInfo['emailOwner'],
                            manageStartWalkInfo['emailWalker'],
                            manageStartWalkInfo['idBusiness'],
                          );
                          await newStartWalk(
                              manageStartWalkInfo['idWalk'],
                              manageStartWalkInfo['emailOwner'],
                              manageStartWalkInfo['emailWalker'],
                              manageStartWalkInfo['idBusiness'],
                              id);
                          toastF('Aceptar');
                          setState(() {
                            for (var data in pendingRequestsData) {
                              deletePreHistory(data['requestId']);
                            }
                            pendingRequestsData.clear();
                          });
                          setState(() {
                            _fetchAndShowNotifications(email!);
                          });
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.check, color: Colors.white),
                            Text(
                              'Aceptar',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            )
                          ],
                        )),
                    TextButton(
                        onPressed: () {
                          toastF('Denegar');
                          deletePreHistory(requestId);
                          setState(() {
                            pendingRequestsData.removeAt(index);
                          });
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.close,
                                color: Color.fromARGB(255, 239, 62, 49)),
                            Text(
                              'Denegar',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 239, 62, 49),
                                  fontSize: 10),
                            )
                          ],
                        )),
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
