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
  bool? lang; // true for Spanish, false for English
  bool? typePremium;

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
    final pendingRequests = await fetchPendingRequestEnd(email!);
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

        String viewUser;
        if (email == doc['emailWalker']) {
          viewUser = doc['emailOwner'];
        } else {
          viewUser = doc['emailWalker'];
        }

        // Fetching user data from Firestore
        Future<Map<String, dynamic>> fetchUserDataAndPremiumStatus(
            String email) async {
          // Fetching the user's document
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where("email", isEqualTo: email)
              .limit(1)
              .get();
          final userDoc = userSnapshot.docs.first;

          // Fetching premium status
          final typePremium = await getPremiumStatus(email);

          return {
            'userDoc': userDoc,
            'typePremium': typePremium,
          };
        }

        return FutureBuilder<Map<String, dynamic>>(
          future: fetchUserDataAndPremiumStatus(viewUser),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final userDoc = snapshot.data!['userDoc'];
            final typePremium = snapshot.data!['typePremium'];
            final profilePhoto = userDoc['profilePhoto'] ?? '';

            // Calculate rating
            List<double> ratings = (userDoc['rating'] as List<dynamic>)
                .map((e) => e is int ? e.toDouble() : e as double)
                .toList();
            double rating = ratings.isNotEmpty
                ? (ratings.reduce((a, b) => a + b) / ratings.length)
                : 0.0;
            final name = userDoc['name'] ?? 'Desconocido';

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 52, 91, 146)
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      image: typePremium == true
                          ? const DecorationImage(
                              image: NetworkImage(
                                  'https://img.freepik.com/free-vector/luxury-background-3d-gradient-design_343694-2843.jpg?w=1060&t=st=1727284022~exp=1727284622~hmac=9434f20079f35f6d7dac9ae8bac9b2331dc12262659ab531b428ce45ebd1be59'),
                              fit: BoxFit.cover,
                            )
                          : null),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang!
                              ? 'Terminar viaje con: $name'
                              : 'End walk with: $name',
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
                                  size: 13,
                                ),
                                Icon(
                                  rating > 1 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 13,
                                ),
                                Icon(
                                  rating > 2 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 13,
                                ),
                                Icon(
                                  rating > 3 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 13,
                                ),
                                Icon(
                                  rating > 4 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 13,
                                ),
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
                          onPressed: _loadingStates[requestId] == true
                              ? null
                              : () async {
                                  setState(() {
                                    _loadingStates[requestId] = true;
                                  });
                                  try {
                                    // Handle end walk logic here...
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
                                  lang! ? 'Terminar' : 'End',
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
