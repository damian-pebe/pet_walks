// ignore_for_file: non_constant_identifier_names, empty_catches, deprecated_member_use

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  late BitmapDescriptor iconPremium;
  Marker? selectedMarker;
  LatLng? selectedPosition;
  String? domicilio;
  LatLng? _center;
  bool _isPermissionGranted = false;

  Set<Marker> markers = {};

  Future<void> _filterWalks(String? time, String? payment) async {
    markers.clear();
    try {
      Set<Map<String, dynamic>> WalksData = await getWalks();
      for (var marker in WalksData) {
        try {
          if (marker['timeWalking'] != null) {
            if (time != null && marker['timeWalking'] != time) {
              continue; // Skip this marker if time doesn't match
            }
          }

          if (payment != null && marker['payMethod'] != payment) {
            continue; // Skip this marker if payment doesn't match
          }

          var geoPoint = marker['position'];
          if (geoPoint is GeoPoint) {
            LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
            markers.add(Marker(
              markerId: MarkerId(marker['timeWalking'] ?? 'Travel'),
              position: latLng,
              icon: marker['premium'] ? iconPremium : icon,
              infoWindow: const InfoWindow(
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
                    id: marker['id'],
                    idBusiness: marker['idBusiness']);
              },
            ));
          } else {}
        } catch (e) {}
      }
      setState(() {});
    } catch (e) {}
  }

  Future<void> _getWalks() async {
    try {
      Set<Map<String, dynamic>> WalksData = await getWalks();
      for (var marker in WalksData) {
        try {
          var geoPoint = marker['position'];
          if (geoPoint is GeoPoint) {
            LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
            markers.add(Marker(
              markerId: MarkerId(marker['timeWalking'] ?? 'Travel'),
              position: latLng,
              icon: marker['premium'] ? iconPremium : icon,
              infoWindow: const InfoWindow(
                title: 'Paseo/Viaje',
              ),
              onTap: () {
                _showBottomSheet(
                    timeWalking: marker['timeWalking'] ?? '',
                    payMethod: marker['payMethod'] ?? 'Unknown',
                    price: marker['price'] ?? 'Unknown',
                    walkWFriends: marker['walkWFriends'] ?? 'Unknown',
                    place: marker['address'] ?? 'Unknown',
                    selectedPets:
                        List<String>.from(marker['selectedPets'] ?? []),
                    description:
                        marker['description'] ?? 'No description available',
                    travelTo: marker['addressBusiness'] ?? '',
                    travelToPosition:
                        marker['positionBusiness'] ?? const GeoPoint(0, 0),
                    email: marker['ownerEmail'],
                    id: marker['id'],
                    idBusiness: marker['idBusiness']);
              },
            ));
          } else {}
        } catch (e) {}
      }

      setState(() {});
    } catch (e) {}
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
    idBusiness,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
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
            id: id,
            idBusiness: idBusiness);
      },
    );
  }

  String? timeWalking;
  String? payMethod;
  DIALOG() {
    showModalBottomSheet(
        backgroundColor: const Color.fromRGBO(250, 244, 229, 1),
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  lang! ? 'Filtraar paseos' : 'Filter walks',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const Divider(),
              Column(
                children: [
                  Text(
                    lang! ? 'Tiempo(min):' : 'Time for walk(min)',
                    style: const TextStyle(
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          timeWalking != '15'
                              ? setState(() {
                                  timeWalking = '15';
                                })
                              : setState(() {
                                  timeWalking = null;
                                });

                          Navigator.pop(context);
                          DIALOG();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: timeWalking == '15'
                                ? Colors.black
                                : const Color.fromRGBO(250, 244, 229, 1),
                            width: 2,
                          ),
                        ),
                        child: Text('15',
                            style: TextStyle(
                              color: timeWalking == '15'
                                  ? Colors.black
                                  : Colors.black,
                            )),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          timeWalking != '30'
                              ? setState(() {
                                  timeWalking = '30';
                                })
                              : setState(() {
                                  timeWalking = null;
                                });

                          Navigator.pop(context);
                          DIALOG();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: timeWalking == '30'
                                ? Colors.black
                                : const Color.fromRGBO(250, 244, 229, 1),
                            width: 2,
                          ),
                        ),
                        child: Text('30',
                            style: TextStyle(
                              color: timeWalking == '30'
                                  ? Colors.black
                                  : Colors.black,
                            )),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          timeWalking != '45'
                              ? setState(() {
                                  timeWalking = '45';
                                })
                              : setState(() {
                                  timeWalking = null;
                                });

                          Navigator.pop(context);
                          DIALOG();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: timeWalking == '45'
                                ? Colors.black
                                : const Color.fromRGBO(250, 244, 229, 1),
                            width: 2,
                          ),
                        ),
                        child: Text('45',
                            style: TextStyle(
                              color: timeWalking == '45'
                                  ? Colors.black
                                  : Colors.black,
                            )),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      timeWalking != 'Viaje'
                          ? setState(() {
                              timeWalking = 'Viaje';
                            })
                          : setState(() {
                              timeWalking = null;
                            });

                      Navigator.pop(context);
                      DIALOG();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: timeWalking == 'Viaje'
                            ? Colors.black
                            : const Color.fromRGBO(250, 244, 229, 1),
                        width: 2,
                      ),
                    ),
                    child: Text(lang! ? 'Viaje' : 'Travel',
                        style: TextStyle(
                          color: timeWalking == 'Viaje'
                              ? Colors.black
                              : Colors.black,
                        )),
                  ),
                  Text(
                    lang! ? 'Metodo de pago' : 'Payment method',
                    style: const TextStyle(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          payMethod != 'Efectivo'
                              ? setState(() {
                                  payMethod = 'Efectivo';
                                })
                              : setState(() {
                                  payMethod = null;
                                });
                          Navigator.pop(context);
                          DIALOG();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: payMethod == 'Efectivo'
                                ? Colors.black
                                : const Color.fromRGBO(250, 244, 229, 1),
                            width: 2,
                          ),
                        ),
                        child: Icon(Icons.attach_money_outlined,
                            color: payMethod == 'Efectivo'
                                ? Colors.black
                                : Colors.black),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          payMethod != 'Tarjeta'
                              ? setState(() {
                                  payMethod = 'Tarjeta';
                                })
                              : setState(() {
                                  payMethod = null;
                                });

                          Navigator.pop(context);
                          DIALOG();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: payMethod == 'Tarjeta'
                                ? Colors.black
                                : const Color.fromRGBO(250, 244, 229, 1),
                            width: 2,
                          ),
                        ),
                        child: Icon(Icons.credit_card_sharp,
                            color: payMethod == 'Tarjeta'
                                ? Colors.black
                                : Colors.black),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0),
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _filterWalks(timeWalking, payMethod);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          lang! ? 'Filtrar' : 'Filter',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Icons.settings_applications_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 15,
              ),
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    timeWalking = null;
                    payMethod = null;
                    _getWalks();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_forever_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                      Text(
                        lang! ? 'Quitar' : 'Remove',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 10,
              )
            ],
          );
        });
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
    } catch (e) {}
  }

  Future<void> initData() async {
    await setIcon();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(walkMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
    Uint8List iconPremiumBytes =
        await Utils.getBytesFromAsset(walkMarkerDeluxe, 140); //premium
    iconPremium = BitmapDescriptor.fromBytes(iconPremiumBytes);
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
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
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
                  const Center(
                      child: SpinKitSpinningLines(
                          color: Color.fromRGBO(169, 200, 149, 1), size: 50.0)),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(169, 200, 149, .2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      color: Colors.black,
                      iconSize: 30,
                      onPressed: () {
                        DIALOG();
                      },
                      icon: Column(
                        children: [
                          const Icon(Icons.settings),
                          Text(lang! ? 'Filtros' : 'Filters')
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
