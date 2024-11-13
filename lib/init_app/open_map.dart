// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches, deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/init_app/servicios/markers_details/business_details.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/utils/constans.dart';

class OpenMap extends StatefulWidget {
  const OpenMap({super.key});

  @override
  State<OpenMap> createState() => _OpenMap();
}

class _OpenMap extends State<OpenMap> {
  late latLng.LatLng _center;

  Marker? selectedMarker;
  map.LatLng? selectedPosition;
  String? domicilio;
  bool _isPermissionGranted = false;
  late var geoPoint;
  List<Marker> markers = [];

  Future<void> _getBusiness() async {
    try {
      Set<Map<String, dynamic>> businessData = await getBusiness();
      for (var marker in businessData) {
        try {
          geoPoint = marker['position'];
          if (geoPoint is GeoPoint) {
            latLng.LatLng latLngPosition =
                latLng.LatLng(geoPoint.latitude, geoPoint.longitude);
            bool isPremium = marker['premium'] ?? false;

            String assetPath =
                isPremium ? businessMarkerDeluxe : businessMarker;

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
                  List<double> ratings = (marker['rating'] as List<dynamic>)
                      .where((e) => e != null) // Remove null values
                      .map((e) =>
                          e is int ? e.toDouble() : (e is double ? e : 0.0))
                      .toList();

                  double rating = ratings.isNotEmpty
                      ? (ratings.reduce((a, b) => a + b) / ratings.length)
                      : 0.0;

                  _showBottomSheet(
                      position: latLngPosition,
                      name: marker['name'] ?? 'Unknown',
                      address: marker['address'] ?? 'Unknown',
                      phone: marker['phone'] ?? 'Unknown',
                      description:
                          marker['description'] ?? 'No description available',
                      rating: rating,
                      imageUrls: marker['imageUrls'] != null &&
                              marker['imageUrls'] is List
                          ? List<String>.from(marker['imageUrls'])
                          : ['https://via.placeholder.com/1500x500'],
                      comments: marker['comments'] ?? [],
                      id: marker['id'] ?? "",
                      category: marker['category'] ?? '');
                },
              ),
            ));
          } else {}
        } catch (e) {}
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {}
  }

  void _showBottomSheet(
      {required String name,
      required String address,
      required String phone,
      required String description,
      required double rating,
      required List<String> imageUrls,
      required List<dynamic> comments,
      required latLng.LatLng position,
      required String id,
      required String category}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BusinessDetails(
            name: name,
            address: address,
            phone: phone,
            description: description,
            rating: rating,
            imageUrls: imageUrls,
            comments: comments,
            geoPoint: map.LatLng(position.latitude, position.longitude),
            id: id,
            category: category);
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
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _center = latLng.LatLng(position.latitude, position.longitude);
          _isPermissionGranted = true;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
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
        ));
  }
}
