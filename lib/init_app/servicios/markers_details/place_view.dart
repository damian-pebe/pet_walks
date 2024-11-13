// ignore_for_file: library_private_types_in_public_api, empty_catches, deprecated_member_use

import 'dart:async';

import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class ViewPlaceMap extends StatefulWidget {
  final map.LatLng position;
  final bool lang;

  const ViewPlaceMap({super.key, required this.position, required this.lang});

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<ViewPlaceMap> {
  List<Marker> markers = [];
  int currentMarkerIndex = 0;

  @override
  void initState() {
    super.initState();
    initData();

    _center =
        latLng.LatLng(widget.position.latitude, widget.position.longitude);
  }

  Future<void> initData() async {
    _createMarker();
  }

  late latLng.LatLng _center;

  void _createMarker() {
    setState(() {
      markers.add(
        Marker(
            point: _center,
            width: 80,
            height: 80,
            child: TextButton(
              child: Image.asset(
                walkMarker,
                width: 80,
                height: 80,
              ),
              onPressed: () {},
            )),
      );
    });
  }

  void _moveToMarker() {
    setState(() {
      if (markers.isNotEmpty) {
        _center = markers[currentMarkerIndex].point;
        currentMarkerIndex = (currentMarkerIndex + 1) % markers.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                onPressed: () => _moveToMarker(),
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
