import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/init_app/servicios/markers_details/walk_details.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/utils/utils.dart';

class Pasear extends StatefulWidget {
  const Pasear({super.key});

  @override
  State<Pasear> createState() => _PasearState();
}

class _PasearState extends State<Pasear> {
  Completer<GoogleMapController> googleMapController = Completer();
  late CameraPosition initialCameraPosition;
  late BitmapDescriptor icon;
  Marker? selectedMarker;
  LatLng? selectedPosition;
  String? domicilio;
  LatLng? _center;
  bool _isPermissionGranted = false;

  Set<Marker> markers = {};

  Future<void> _getWalks() async {
    try {
      Set<Map<String, dynamic>> _WalksData = await getWalks();
      for (var marker in _WalksData) {
        try {
          var geoPoint = marker['position'];
          if (geoPoint is GeoPoint) {
            LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
            markers.add(Marker(
              markerId: MarkerId(marker['timeWalking'] ?? 'Travel'),
              position: latLng,
              icon: icon,
              infoWindow: InfoWindow(
                title: 'Paseo/Viaje',
              ),
              onTap: () {
                _showBottomSheet(
                    timeWalking: marker['timeWalking'] ?? 'Unknown',
                    payMethod: marker['payMethod'] ?? 'Unknown',
                    price: marker['price'] ?? 'Unknown',
                    walkWFriends: marker['walkWFriends'] ?? 'Unknown',
                    place: marker['address'] ?? 'Unknown',
                    selectedPets:
                        List<String>.from(marker['selectedPets'] ?? []),
                    description:
                        marker['description'] ?? 'No description available',
                    travelTo: marker['travelTo'] ?? '',
                    travelToPosition:
                        marker['travelToPosition'] ?? const GeoPoint(0, 0),
                    email: marker['ownerEmail'],
                    id: marker['id']);
              },
            ));
          } else {
            print("Invalid GeoPoint for marker: ${marker['timeWalking']}");
          }
        } catch (e) {
          print("Error processing marker: ${marker['timeWalking']} - $e");
        }
      }

      setState(() {});
    } catch (e) {
      print("Error fetching business data: $e");
    }
  }

  void _showBottomSheet({
    required payMethod,
    required price,
    required walkWFriends,
    required timeWalking,
    required place,
    required description,
    required selectedPets,
    required travelTo,
    required travelToPosition,
    required email,
    required id,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        print(travelToPosition);

        return WalkDetails(
            payMethod: payMethod,
            price: price,
            walkWFriends: walkWFriends,
            timeWalking: timeWalking,
            place: place,
            description: description,
            selectedPets: selectedPets,
            travelTo: travelTo,
            travelToPosition: travelToPosition,
            ownerEmail: email,
            id: id);
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
      _getWalks();
    });
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
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
          _center = LatLng(position.latitude, position.longitude);
          _isPermissionGranted = true;
        });
      }
    } catch (e) {
      print("ERROR CON UBICACION: $e");
    }
  }

  Future<void> initData() async {
    await setIcon();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(walkMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: lang == null
          ? null
          : AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    lang! ? 'Pasear mascotas' : 'Walk pets',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.pets)
                ],
              ),
              backgroundColor: const Color.fromRGBO(169, 200, 149, 1),
            ),
      body: lang == null
          ? null
          : Stack(
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
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
