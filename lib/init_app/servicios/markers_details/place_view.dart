// ignore_for_file: library_private_types_in_public_api, empty_catches, deprecated_member_use

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/utils/utils.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class ViewPlaceMap extends StatefulWidget {
  final LatLng position;
  final bool lang;

  const ViewPlaceMap({super.key, required this.position, required this.lang});

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<ViewPlaceMap> {
  GoogleMapController? _mapController;
  List<Marker> markers = [];
  late BitmapDescriptor icon;
  int currentMarkerIndex = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await setIcon();
    _createMarker();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(walkMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  void _createMarker() {
    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId('Go to/Ir a'),
          position: widget.position, // Use widget.position
          infoWindow: const InfoWindow(title: 'Go to/Ir a'),
          icon: icon,
        ),
      );
    });
  }

  void _moveToMarker(int index) {
    if (index >= 0 && index < markers.length) {
      LatLng markerPosition = markers[index].position;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: markerPosition,
            zoom: 18,
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.position,
              zoom: 18,
            ),
            markers: Set<Marker>.of(markers), // Use markers list
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          titleW(
              title: widget.lang ? '  Lugar seleccionado' : '  Place selected'),
          Positioned(
            left: 10,
            top: 60,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios,
                  size: 30, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            child: IconButton.filledTonal(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[200]),
                ),
                onPressed: () => _moveToMarker(currentMarkerIndex),
                icon: const Icon(
                  Icons.mode_of_travel_outlined,
                  size: 30,
                )),
          )
        ],
      ),
    );
  }
}
