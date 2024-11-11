import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/toast.dart';

class OpenMapGuest extends StatefulWidget {
  const OpenMapGuest({super.key});

  @override
  State<OpenMapGuest> createState() => _OpenMap();
}

class _OpenMap extends State<OpenMapGuest> {
  late latLng.LatLng _center;
  List<Marker> markers = [];
  bool _isPermissionGranted = false;

  Future<void> _getBusiness() async {
    Set<Map<String, dynamic>> businessData = await getBusiness();
    for (var markerData in businessData) {
      var geoPoint = markerData['position'];
      if (geoPoint is GeoPoint) {
        latLng.LatLng latLngPosition =
            latLng.LatLng(geoPoint.latitude, geoPoint.longitude);
        bool isPremium = markerData['premium'] ?? false;

        String assetPath = isPremium ? businessMarkerDeluxe : businessMarker;

        markers.add(Marker(
          point: latLngPosition,
          width: 80,
          height: 80,
          child: TextButton(
            child: Image.asset(
              assetPath,
              width: 80,
              height: 80,
            ),
            onPressed: () {
              List<double> ratings = (markerData['rating'] as List<dynamic>)
                  .map((e) => e is int ? e.toDouble() : e as double)
                  .toList();
              double rating = ratings.isNotEmpty
                  ? (ratings.reduce((a, b) => a + b) / ratings.length)
                  : 0.0;

              _showBottomSheet(
                position: latLngPosition,
                name: markerData['name'] ?? 'Unknown',
                address: markerData['address'] ?? 'Unknown',
                phone: markerData['phone'] ?? 'Unknown',
                description:
                    markerData['description'] ?? 'No description available',
                rating: rating,
                imageUrls: markerData['imageUrls'] != null &&
                        markerData['imageUrls'] is List
                    ? List<String>.from(markerData['imageUrls'])
                    : ['https://via.placeholder.com/1500x500'],
                comments: markerData['comments'] ?? [],
              );
            },
          ),
        ));
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showBottomSheet({
    required String name,
    required String address,
    required String phone,
    required String description,
    required double rating,
    required List<String> imageUrls,
    required List<dynamic> comments,
    required latLng.LatLng position,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BusinessDetailsGuest(
          name: name,
          address: address,
          phone: phone,
          description: description,
          rating: rating,
          imageUrls: imageUrls,
          comments: comments,
          geoPoint: position,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _getBusiness();
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      if (await Permission.location.request().isGranted) {
        _getCurrentLocation();
      } else {
        _checkLocationPermission();
      }
    } else {
      _getCurrentLocation();
    }
  }

  void _getCurrentLocation() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _center = latLng.LatLng(position.latitude, position.longitude);
        _isPermissionGranted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isPermissionGranted)
            FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 17,
              ),
              children: [
                TileLayer(
                  urlTemplate: urlMap,
                ),
                MarkerLayer(markers: markers),
              ],
            )
          else
            const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0)),
        ],
      ),
    );
  }
}

class BusinessDetailsGuest extends StatelessWidget {
  final String name;
  final String address;
  final String phone;
  final String description;
  final double rating;
  final List<String> imageUrls;
  final List<dynamic> comments;
  final latLng.LatLng geoPoint;

  const BusinessDetailsGuest({
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.rating,
    required this.imageUrls,
    required this.comments,
    required this.geoPoint,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 200,
                child: PhotoCarousel(
                  imageUrls: imageUrls.isNotEmpty ? imageUrls : [],
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text("Address: $address"),
            Text("Phone: $phone"),
            const Divider(),
            Row(
              children: [
                Icon(rating > 0 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(rating > 1 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(rating > 2 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(rating > 3 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(rating > 4 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                const SizedBox(width: 8.0),
                Text("$rating/5"),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    toastF(
                      'Log in to use this function',
                    );
                  },
                  child: const Text(
                    "Comments",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(width: 50),
                IconButton(
                  onPressed: () {
                    toastF('First, Log In');
                  },
                  icon: const Icon(
                    Icons.report_outlined,
                    size: 35,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
