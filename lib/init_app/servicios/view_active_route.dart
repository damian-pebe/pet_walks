import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/utils/utils.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:petwalks_app/widgets/decorations.dart';

class RouteMap extends StatefulWidget {
  final String idWalk;
  final bool lang;

  const RouteMap({Key? key, required this.idWalk, required this.lang})
      : super(key: key);

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _mapController;
  List<LatLng> route = [];
  List<Marker> markers = [];
  Set<Polyline> polylines = {};
  late BitmapDescriptor icon;
  LatLng? _center;
  bool _isPermissionGranted = false;
  int currentMarkerIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    initData().then((_) {
      fetchAndDisplayRoute();
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
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _isPermissionGranted = true;
        });
      }
    } catch (e) {
      print("ERROR WITH LOCATION: $e");
    }
  }

  Future<void> initData() async {
    await setIcon();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(walkMarker, 105);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  void fetchAndDisplayRoute() {
    FirebaseFirestore.instance
        .collection('history')
        .doc(widget.idWalk)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        List<LatLng> newRoute = [];
        var data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> positions = data['position'] ?? [];

        for (var pos in positions) {
          double lat = pos['lat'];
          double lng = pos['lng'];
          newRoute.add(LatLng(lat, lng));
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

  List<Marker> _createMarkers(List<LatLng> route) {
    return route.asMap().entries.map((entry) {
      return Marker(
        markerId: MarkerId(entry.key.toString()),
        position: entry.value,
        icon: icon,
        infoWindow: InfoWindow(
          title: 'Marker ${entry.key + 1}',
        ),
      );
    }).toList();
  }

  Set<Polyline> _createPolylines(List<LatLng> route) {
    return {
      Polyline(
        polylineId: PolylineId("route"),
        points: route,
        color: Colors.blue,
        width: 5,
      ),
    };
  }

  void _moveToMarker(int index) {
    if (index >= 0 && index < markers.length) {
      LatLng markerPosition = markers[index].position;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: markerPosition,
            zoom: 20,
          ),
        ),
      );
      setState(() {
        currentMarkerIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isPermissionGranted
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center ?? LatLng(0, 0),
                    zoom: 20,
                  ),
                  markers: Set<Marker>.of(markers),
                  polylines: polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
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
                          icon: Icon(Icons.arrow_back_ios,
                              size: 30, color: Colors.black),
                        ),
                        Text(
                          widget.lang ? 'Regresar' : 'Back',
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    )),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
