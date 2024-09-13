import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  Location _location = Location();
  List<LatLng> _trackedLocations = [];
  late String _userId;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
    _fetchLocationsFromFirestore();
  }

  void _initializeLocationTracking() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      final LatLng newLocation =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);

      _updateLocationInFirestore(newLocation);

      setState(() {
        _trackedLocations.add(newLocation);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(newLocation),
      );
    });
  }

  void _updateLocationInFirestore(LatLng newLocation) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'trackedLocations': FieldValue.arrayUnion([
          {'lat': newLocation.latitude, 'lng': newLocation.longitude}
        ])
      });
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void _fetchLocationsFromFirestore() async {
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (docSnapshot.exists) {
      List<dynamic> locations = docSnapshot['trackedLocations'] ?? [];
      setState(() {
        _trackedLocations = locations
            .map((location) => LatLng(location['lat'], location['lng']))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Your Walk')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('tracking_line'),
            color: Colors.blue,
            width: 5,
            points: _trackedLocations,
          ),
        },
      ),
    );
  }
}
