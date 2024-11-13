// ignore_for_file: library_private_types_in_public_api, empty_catches, deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:petwalks_app/widgets/decorations.dart';

class RouteMap extends StatefulWidget {
  final String idWalk;
  final bool lang;

  const RouteMap({super.key, required this.idWalk, required this.lang});

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  List<latLng.LatLng> route = [];
  List<Marker> markers = [];
  Set<Polyline> polylines = {};
  late latLng.LatLng _center;
  bool _isPermissionGranted = false;
  int currentMarkerIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    fetchAndDisplayRoute();
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
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _center = latLng.LatLng(position.latitude, position.longitude);
          _isPermissionGranted = true;
        });
      }
    } catch (e) {}
  }

  void fetchAndDisplayRoute() {
    FirebaseFirestore.instance
        .collection('history')
        .doc(widget.idWalk)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        List<latLng.LatLng> newRoute = [];
        var data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> positions = data['position'] ?? [];

        for (var pos in positions) {
          double lat = pos['lat'];
          double lng = pos['lng'];
          newRoute.add(latLng.LatLng(lat, lng));
        }

        if (newRoute.isNotEmpty) {
          if (mounted) {
            setState(() {
              route = newRoute;
              markers = _createMarkers(newRoute);
              polylines = _createPolylines(newRoute);
            });
          }
        }
      }
    });
  }

  List<Marker> _createMarkers(List<latLng.LatLng> route) {
    return route.asMap().entries.map((entry) {
      return Marker(
        point: entry.value,
        width: 80,
        height: 80,
        child: Image.asset(
          walkMarker,
          width: 80,
          height: 80,
        ),
      );
    }).toList();
  }

  Set<Polyline> _createPolylines(List<latLng.LatLng> route) {
    return {
      Polyline(
        points: route,
        color: Colors.blue,
        strokeWidth: 5.0,
      ),
    };
  }

  void _moveToMarker(int index) {
    setState(() {
      if (markers.isNotEmpty) {
        _center = markers[index].point;
        index = (index + 1) % markers.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isPermissionGranted
          ? Stack(
              children: [
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
                ),
                Positioned(
                  bottom: 20.0,
                  left: 10,
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _moveToMarker(currentMarkerIndex - 1);
                        },
                        style: customOutlinedButtonStyle(),
                        child: Text(
                          widget.lang ? 'Anterior' : 'Previous',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      OutlinedButton(
                        style: customOutlinedButtonStyle(),
                        onPressed: () {
                          _moveToMarker(currentMarkerIndex + 1);
                        },
                        child: Text(
                          widget.lang ? 'Siguiente' : 'Next',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    left: 30,
                    top: 40,
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back_ios,
                              size: 30, color: Colors.black),
                        ),
                        Text(
                          widget.lang ? 'Regresar' : 'Back',
                          style: const TextStyle(fontSize: 10),
                        )
                      ],
                    )),
              ],
            )
          : const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0)),
    );
  }
}
