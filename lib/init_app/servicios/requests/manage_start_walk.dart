// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/services/fcm_services.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/services/firebase_tracker.dart';
import 'package:petwalks_app/services/twilio.dart';
import 'package:petwalks_app/widgets/toast.dart';

class StartWalkManagement extends StatefulWidget {
  const StartWalkManagement({super.key});

  @override
  State<StartWalkManagement> createState() => _StartWalkManagementState();
}

class _StartWalkManagementState extends State<StartWalkManagement> {
  //!TIMERS
  void handleHalfTime(String email) async {
    await sendNotificationsToUserDevices(email, 'PET WALKS Tiempo de paseo',
        'Te recordamos que su paseo activo va por la mitad');
    String phone = await getUserPhone(email);
    String message = lang!
        ? 'PET WALKS Tiempo de paseo\n Te recordamos que su paseo activo va por la mitad'
        : 'PET WALKS Walk time\nWe remind you that your active walk is half over';
    twilioService.sendSms(phone, message);
  }

  void handleTimeout(String email) async {
    await sendNotificationsToUserDevices(email, 'PET WALKS Tiempo de paseo',
        'Faltn 5 minutos para terminar el viaje, te recomendamos estar preparado para finalizar el viaje');
    String phone = await getUserPhone(email);
    String message = lang!
        ? 'PET WALKS Tiempo de paseo\n Faltn 5 minutos para terminar el viaje, te recomendamos estar preparado para finalizar el viaje'
        : 'PET WALKS Walking time\n There are 5 minutes left to finish the trip, we recommend that you be prepared to finish the trip';
    twilioService.sendSms(phone, message);
  }

  void handleThief(String email) async {
    await sendNotificationsToUserDevices(email, 'PET WALKS Tiempo de paseo',
        'Su viaje debio haber terminado hace 1 hora, porfavor revise el estatus de su viaje en historial, si ya recibio a su mascota y no termino el viaje puede forzar el fin, si no, por favor reporte al usuario desde historial');
    String phone = await getUserPhone(email);
    String message = lang!
        ? 'PET WALKS Estatus de su viaje\n Su viaje debio haber terminado hace 1 hora, porfavor revise el estatus de su viaje en historial, si ya recibio a su mascota y no termino el viaje puede forzar el fin, si no, por favor reporte al usuario desde historial'
        : 'PET WALKS Status of your trip\nYour trip should have ended 1 hour ago, please check the status of your trip in history, if you have already received your pet and have not finished the trip you can force the end, if not, please report to the user from history';
    twilioService.sendSms(phone, message);
  }

  //!TIMERS\
  String? email;
  Map<String, bool> _loadingStates = {};
  List<DocumentSnapshot> _pendingRequests = [];
  bool? lang;

  @override
  void initState() {
    super.initState();
    _fetchEmail();
    _getLanguage();
    generateFourDigitToken();
    twilioService = twilioServiceKeys;
  }

  void generateFourDigitToken() {
    final random = Random();
    int number = 1000 + random.nextInt(9000);
    tokenKey = number.toString();
  }

  late final TwilioService twilioService;
  String? tokenKey;

  bool? typePremium;
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
        String viewUser;

        if (email == doc['emailWalker']) {
          viewUser = doc['emailOwner'];
        } else {
          viewUser = doc['emailWalker'];
        }

        // Fetch the user document using FutureBuilder
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where("email", isEqualTo: viewUser)
              .limit(1)
              .get()
              .then((snapshot) => snapshot.docs.first),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink(); // Loading state
            } else if (snapshot.hasError) {
              return Text(lang!
                  ? 'Error: ${snapshot.error}'
                  : 'Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final walkerDoc = snapshot.data!;
            final profilePhoto = walkerDoc['profilePhoto'] ?? '';

            // Process ratings
            List<double> ratings = (walkerDoc['rating'] as List<dynamic>)
                .map((e) => e is int ? e.toDouble() : e as double)
                .toList();

            double rating = ratings.isNotEmpty
                ? (ratings.reduce((a, b) => a + b) / ratings.length)
                : 0.0;

            final name = walkerDoc['name'] ?? 'Desconocido';

            // Use another FutureBuilder to get the premium status asynchronously
            return FutureBuilder<bool>(
              future: getPremiumStatus(viewUser),
              builder: (context, premiumSnapshot) {
                if (premiumSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox
                      .shrink(); // Loading state for premium status
                }

                bool typePremium = premiumSnapshot.data ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 16.0),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 153, 80, 190),
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
                              : const DecorationImage(
                                  image: NetworkImage(
                                      'https://img.freepik.com/vector-gratis/ilustracion-panoramica-horizonte-edificio-urbano-copyspace_107791-1950.jpg?t=st=1727902238~exp=1727905838~hmac=e484dfa8e5195cdfadafc5c10432ef4b8b61d4fd797c92e7699b483be2d4b6f8&w=1380'),
                                  fit: BoxFit.cover,
                                  opacity: .5)),
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
                                    for (int i = 0; i < 5; i++)
                                      Icon(
                                        i < rating
                                            ? Icons.star
                                            : Icons.star_border,
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
                                        Map<String, dynamic>
                                            manageStartWalkInfo =
                                            await manageStartWalk(requestId);
                                        bool owner =
                                            manageStartWalkInfo['emailOwner'] ==
                                                email;
                                        Map<String, dynamic> walkIfno =
                                            await getInfoWalk(
                                                manageStartWalkInfo['idWalk']);
                                        updateOwner(true, requestId, true);
                                        await Future.delayed(
                                            const Duration(seconds: 10));

                                        bool status = await getWalkerStatus(
                                            requestId, true);
                                        LatLng? walkerPosition =
                                            await getWalkerPosition(
                                                requestId, true);
                                        Position ownerPosition =
                                            await Geolocator.getCurrentPosition(
                                                desiredAccuracy:
                                                    LocationAccuracy.high);
                                        double distanceInMeters = 0;

                                        if (walkerPosition != null) {
                                          distanceInMeters =
                                              Geolocator.distanceBetween(
                                            ownerPosition.latitude,
                                            ownerPosition.longitude,
                                            walkerPosition.latitude,
                                            walkerPosition.longitude,
                                          );
                                        }

                                        if (owner) {
                                          if (status &&
                                              distanceInMeters < 400) {
                                            await newEndWalk(
                                                manageStartWalkInfo['idWalk'],
                                                manageStartWalkInfo[
                                                    'emailOwner'],
                                                manageStartWalkInfo[
                                                    'emailWalker'],
                                                walkIfno['idBusiness'],
                                                manageStartWalkInfo[
                                                    'idHistory']);
                                            updateHistory(
                                                manageStartWalkInfo[
                                                    'idHistory'],
                                                'walking',
                                                DateTime.now(),
                                                true);
                                            toastF('walk started');
                                            if (email ==
                                                manageStartWalkInfo[
                                                    'emailWalker']) {
                                              checkUserAndStartTracking();
                                            }
                                            setState(() {});
                                            await deleteStartHistory(
                                                requestId, true);
                                            setState(() {
                                              _fetchPendingRequests();
                                            });

                                            String? timeToEnd =
                                                walkIfno['walkTime'];
                                            int timeToEndInt =
                                                int.parse(timeToEnd ?? '15');
                                            int timeHalf = timeToEndInt ~/ 2;
                                            int timeEnd = timeToEndInt - 5;
                                            int thief = timeToEndInt + 60;
                                            //!change seconds to minutes for deploy mode
                                            await Future.delayed(
                                                Duration(seconds: timeHalf));

                                            handleHalfTime(manageStartWalkInfo[
                                                'emailWalker']);
                                            handleHalfTime(manageStartWalkInfo[
                                                'emailOwner']);

                                            await Future.delayed(
                                                Duration(seconds: timeEnd));

                                            handleTimeout(manageStartWalkInfo[
                                                'emailWalker']);
                                            handleTimeout(manageStartWalkInfo[
                                                'emailOwner']);

                                            await Future.delayed(
                                                Duration(seconds: thief));

                                            handleThief(manageStartWalkInfo[
                                                'emailOwner']);
                                          } else {
                                            updateOwner(false, requestId, true);
                                            toastF(lang!
                                                ? 'Ambos usuarios deben estar listos y cerca'
                                                : 'both users need to be ready and close to each other');
                                          }
                                        } else {
                                          updateWalker(true, requestId, true);
                                          await Future.delayed(
                                              const Duration(seconds: 10));
                                          updateWalker(false, requestId, true);
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
                                      style:
                                          const TextStyle(color: Colors.white),
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
      },
    );
  }
}
