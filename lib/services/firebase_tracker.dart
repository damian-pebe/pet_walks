import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/services/firebase_services.dart';

Timer? trackingTimer;

void checkUserAndStartTracking() async {
  String email = await fetchUserEmail();

  QuerySnapshot walkDocs = await FirebaseFirestore.instance
      .collection('history')
      .where('emailWalker', isEqualTo: email)
      .where('status', isEqualTo: 'walking')
      .get();

  if (walkDocs.docs.isNotEmpty) {
    DocumentSnapshot walkDoc = walkDocs.docs.first;
    var data = walkDoc.data() as Map<String, dynamic>;

    if (data['emailWalker'] == email) {
      print("startListeningToStatus: ${walkDoc.id}");
      startListeningToStatus(walkDoc.id);
    }
  } else {
    print("No walking history found for this user.");
  }
}

void startListeningToStatus(String idHistoryWalk) {
  FirebaseFirestore.instance
      .collection('history')
      .doc(idHistoryWalk)
      .snapshots()
      .listen((snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data();
      String status = data?['status'] ?? 'unknown';

      if (status == 'walking') {
        if (trackingTimer == null || !trackingTimer!.isActive) {
          print("startTracking.");

          startTracking(idHistoryWalk);
        }
      } else if (status == 'done') {
        print("stopTracking.");

        stopTracking(idHistoryWalk);
      }
    }
  });
}

void startTracking(String idHistoryWalk) {
  trackingTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    savePositionToFirestore(
        LatLng(position.latitude, position.longitude), idHistoryWalk);
  });

  print("Tracking started for walk: $idHistoryWalk");
}

void stopTracking(String idHistoryWalk) {
  if (trackingTimer != null) {
    trackingTimer!.cancel();
    trackingTimer = null;
  }

  print("Tracking stopped for walk: $idHistoryWalk");
}

void savePositionToFirestore(LatLng position, String idHistoryWalk) {
  FirebaseFirestore.instance.collection('history').doc(idHistoryWalk).update({
    'position': FieldValue.arrayUnion([
      {
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': Timestamp.now(),
      }
    ])
  });
}

//here i got everything to show on map and polylines

Future<List<LatLng>> getSavedPositions(String idHistoryWalk) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('history')
      .doc(idHistoryWalk)
      .get();

  if (snapshot.exists) {
    List<LatLng> route = [];

    var data = snapshot.data() as Map<String, dynamic>;
    List<dynamic> positions = data['position'] ?? [];

    for (var pos in positions) {
      double lat = pos['lat'];
      double lng = pos['lng'];
      route.add(LatLng(lat, lng));
    }

    return route;
  }

  return [];
}
