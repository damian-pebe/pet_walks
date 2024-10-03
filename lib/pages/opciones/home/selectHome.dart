import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectHome extends StatefulWidget {
  const SelectHome({Key? key}) : super(key: key);

  @override
  State<SelectHome> createState() => _SelectHome();
}

class _SelectHome extends State<SelectHome> {
  bool lang = true;
  void _getLanguage() async {
    if (await isUserLoggedIn()) {
      lang = await getLanguage();
      if (mounted) setState(() {});
    } else {
      bool savedLang = await getLanguagePreference();
      setState(() {
        lang = savedLang;
      });
    }
  }

  Future<bool> isUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Completer<GoogleMapController> googleMapController = Completer();
  Set<Marker> markers = {};
  late CameraPosition initialCameraPosition;
  late BitmapDescriptor icon;
  Marker? selectedMarker;
  LatLng? selectedPosition;
  String? domicilio;
  LatLng? _center;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    _getLanguage();
    super.initState();
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    _checkLocationPermission();
    initData();
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
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _isPermissionGranted = true;
      });
    } catch (e) {
      print("ERRORRRRRR...... CON LA UBI: $e");
    }
  }

  Future<void> initData() async {
    await setIcon();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(userMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  void addMarker(LatLng nuevaPosicion) async {
    String nuevaDireccion = await getAddressFromLatLng(nuevaPosicion);
    setState(() {
      markers.clear();
      selectedPosition = nuevaPosicion;
      domicilio = nuevaDireccion;
      selectedMarker = Marker(
        markerId: MarkerId(nuevaPosicion.toString()),
        position: nuevaPosicion,
        icon: icon,
      );
      markers.add(selectedMarker!);
    });

    moverCamara(nuevaPosicion);
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
    }
    return 'Dirección no encontrada';
  }

  Future<void> moverCamara(LatLng posicion) async {
    final controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(posicion));
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
              onTap: (LatLng posicion) {
                addMarker(posicion);
              },
            )
          else
            const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0)),
          if (selectedMarker != null)
            Positioned(
              bottom: 130,
              left: 260,
              right: 10,
              child: OutlinedButton(
                onPressed: () {
                  if (selectedPosition != null) {
                    Navigator.pop(context,
                        {'domicilio': domicilio, 'position': selectedPosition});
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(width: 2.0, color: Colors.black),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang ? 'Aceptar' : 'Accept',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.check_circle_outline,
                      size: 25,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                domicilio == null
                    ? 'Seleccion: '
                    : lang
                        ? 'Seleccion: $domicilio'
                        : 'Selection: $domicilio',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 2.0,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
