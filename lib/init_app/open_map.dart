// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches, deprecated_member_use

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/init_app/servicios/markers_details/business_details.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/utils/utils.dart';

class OpenMap extends StatefulWidget {
  const OpenMap({super.key});

  @override
  State<OpenMap> createState() => _OpenMap();
}

class _OpenMap extends State<OpenMap> {
  Completer<GoogleMapController> googleMapController = Completer();
  late CameraPosition initialCameraPosition;
  late BitmapDescriptor icon;
  late BitmapDescriptor iconPremium;

  Marker? selectedMarker;
  LatLng? selectedPosition;
  String? domicilio;
  LatLng? _center;
  bool _isPermissionGranted = false;
  late var geoPoint;
  Set<Marker> markers = {};

  Future<void> _getBusiness() async {
    Set<Map<String, dynamic>> businessData = await getBusiness();
    for (var marker in businessData) {
      geoPoint = marker['position'];
      if (geoPoint is GeoPoint) {
        LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
        markers.add(Marker(
          markerId: MarkerId(marker['name'] ?? 'Unknown'),
          position: latLng,
          icon: marker['premium'] ? iconPremium : icon,
          infoWindow: InfoWindow(
            title: marker['name'] ?? 'Unknown',
            snippet: marker['description'] ?? 'No description available',
          ),
          onTap: () {
            List<double> ratings = (marker['rating'] as List<dynamic>)
                .map((e) => e is int ? e.toDouble() : e as double)
                .toList();
            double rating = ratings.isNotEmpty
                ? (ratings.reduce((a, b) => a + b) / ratings.length)
                : 0.0;

            _showBottomSheet(
              position: latLng,
              name: marker['name'] ?? 'Unknown',
              address: marker['address'] ?? 'Unknown',
              phone: marker['phone'] ?? 'Unknown',
              description: marker['description'] ?? 'No description available',
              rating: rating,
              imageUrls:
                  marker['imageUrls'] != null && marker['imageUrls'] is List
                      ? List<String>.from(marker['imageUrls'])
                      : ['https://via.placeholder.com/1500x500'],
              comments: marker['comments'] ?? [],
            );
          },
        ));
      } else {}
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showBottomSheet(
      {required String name,
      required String address,
      required String phone,
      required String description,
      required double rating,
      required List<String> imageUrls,
      required List<dynamic> comments,
      required LatLng position}) {
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
          geoPoint: position,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    _checkLocationPermission();
    initData().then((_) {
      _getBusiness();
    });
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
        _center = LatLng(position.latitude, position.longitude);
        _isPermissionGranted = true;
      });
    }
  }

  Future<void> initData() async {
    await setIcon();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(businessMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
    Uint8List iconPremiumBytes =
        await Utils.getBytesFromAsset(businessMarkerDeluxe, 140); //premium
    iconPremium = BitmapDescriptor.fromBytes(iconPremiumBytes);
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
                GoogleMap(
                  markers: markers,
                  mapType: MapType.normal,
                  initialCameraPosition: _center == null
                      ? initialCameraPosition
                      : CameraPosition(
                          target: _center!,
                          zoom: 17,
                        ),
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController.complete(controller);
                  },
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
