// ignore_for_file: empty_catches

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
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/toast.dart';

class OpenMapGuest extends StatefulWidget {
  const OpenMapGuest({super.key});

  @override
  State<OpenMapGuest> createState() => _OpenMap();
}

class _OpenMap extends State<OpenMapGuest> {
  Completer<GoogleMapController> googleMapController = Completer();
  late CameraPosition initialCameraPosition;
  late BitmapDescriptor icon;
  Marker? selectedMarker;
  LatLng? selectedPosition;
  String? domicilio;
  LatLng? _center;
  bool _isPermissionGranted = false;
  // ignore: prefer_typing_uninitialized_variables
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
          icon: icon,
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
    // ignore: deprecated_member_use
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class BusinessDetailsGuest extends StatefulWidget {
  final String name;
  final String address;
  final String phone;
  final String description;
  final double rating;
  final List<String> imageUrls;
  final List<dynamic> comments;
  final LatLng geoPoint;

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
  State<BusinessDetails> createState() => _BusinessDetailsState();
}

class _BusinessDetailsState extends State<BusinessDetails> {
  @override
  void initState() {
    matchId();
    super.initState();
  }

  String? id;
  matchId() async {
    id = await findMatchingBusinessId(widget.address);
  }

  bool lang = true;
  Future<void> getLang() async {
    bool savedLang = await getLanguagePreference();
    setState(() {
      lang = savedLang;
    });
  }

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
                  imageUrls:
                      widget.imageUrls.isNotEmpty ? widget.imageUrls : [],
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text("Address: ${widget.address}"),
            Text("Phone: ${widget.phone}"),
            const Divider(),
            Row(
              children: [
                Icon(widget.rating > 0 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(widget.rating > 1 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(widget.rating > 2 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(widget.rating > 3 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                Icon(widget.rating > 4 ? Icons.star : Icons.star_border,
                    color: Colors.amber),
                const SizedBox(width: 8.0),
                Text("${widget.rating}/5"),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    toastF(
                      lang
                          ? 'Inicia sesion para utilizar esta funcion'
                          : 'Log in to use this function',
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
                    toastF('Fisrt, Log In');
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
              widget.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
