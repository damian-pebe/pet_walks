import 'dart:async';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/init_app/servicios/add_post.dart';
import 'package:petwalks_app/init_app/servicios/markers_details/social_details.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/utils/utils.dart';

class SocialNetwork extends StatefulWidget {
  const SocialNetwork({super.key});

  @override
  State<SocialNetwork> createState() => _SocialNetwork();
}

class _SocialNetwork extends State<SocialNetwork> {
  Completer<GoogleMapController> googleMapController = Completer();
  late CameraPosition initialCameraPosition;
  late BitmapDescriptor icon;
  Marker? selectedMarker;
  LatLng? selectedPosition;
  String? domicilio;
  LatLng? _center;
  bool _isPermissionGranted = false;
  Set<Marker> markers = {};
  var showData;

  Future<void> _getPosts(Set<Map<String, dynamic>> idsAddress) async {
    if (idsAddress.isNotEmpty) {
      String addressToCheck = idsAddress.first['address'];

      List<String> idsWithSameAddress = [];
      for (var element in idsAddress) {
        if (element['address'] == addressToCheck) {
          idsWithSameAddress.add(element['id']);
        }
      }

      idsAddress.removeWhere((element) => element['address'] == addressToCheck);

      _addMarker(idsWithSameAddress, addressToCheck);

      if (idsAddress.isNotEmpty) {
        await _getPosts(idsAddress);
      }
    }
  }

  Future<void> _addMarker(
      List<String> idsWithSameAddress, String addressToCheck) async {
    LatLng? position = await getLatLngFromAddress(addressToCheck);

    if (position != null) {
      markers.add(Marker(
        markerId: const MarkerId('Publicacion'),
        position: position,
        icon: icon,
        onTap: () {
          _showBottomSheet(postIds: idsWithSameAddress);
        },
      ));
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _showBottomSheet({
    required List<String> postIds,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SocialNetworkDetails(
          postIds: postIds,
        );
      },
    );
  }

  void _showBottomSheetAlone({
    required List<String> postIds,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SocialNetworkDetailsAlone(
          postIds: postIds,
        );
      },
    );
  }

  late Set<Map<String, dynamic>> idsAddress;
  void _arrayPost() async {
    idsAddress = await getPost();
    _getPosts(idsAddress);
  }

  void _checkArrayDeletedPosts() async {
    await checkArrayDeletedPosts();
    _arrayPost();
  }

  @override
  void initState() {
    super.initState();
    _checkArrayDeletedPosts();
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
      print("ERROR CON UBICACION: $e");
    }
  }

  Future<void> initData() async {
    await setIcon();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(postMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  bool _isTypeWindowVisible = false;

  void toastF(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      textColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const navbarHeight = kBottomNavigationBarHeight;

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
            const Center(child: CircularProgressIndicator()),
          if (!_isTypeWindowVisible)
            Positioned(
              left: 20,
              top: 30,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isTypeWindowVisible = true;
                  });
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                ),
              ),
            ),
          if (_isTypeWindowVisible)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                height: screenHeight - navbarHeight,
                width: 80,
                color: Colors.white.withOpacity(.6),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<Set<Map<String, dynamic>>>(
                        future: ownPosts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('No posts'));
                          } else {
                            return Flexible(
                              child: ListView(
                                shrinkWrap: true,
                                children: snapshot.data!.map((post) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (post['imageUrls'] != null &&
                                          post['imageUrls'].isNotEmpty)
                                        Stack(
                                          children: [
                                            GestureDetector(
                                              child: CircleAvatar(
                                                radius: 40,
                                                backgroundImage: NetworkImage(
                                                    post['imageUrls'][0]),
                                              ),
                                              onTap: () =>
                                                  _showBottomSheetAlone(
                                                      postIds: [post['id']]),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                      size: 17,
                                                    ),
                                                  ),
                                                  onTap: () => showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            true,
                                                        barrierColor: Colors
                                                            .white
                                                            .withOpacity(0.65),
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white
                                                                    .withOpacity(
                                                                        .1),
                                                            actions: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20.0,
                                                                        vertical:
                                                                            50),
                                                                child: Center(
                                                                  child: Text(
                                                                    "¿Estas seguro de querer eliminar a la mascota?",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        await deletePost(
                                                                            post['id']);

                                                                        setState(
                                                                            () {
                                                                          toastF(
                                                                              'Publicacion eliminada');
                                                                        });
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Aceptar',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      )),
                                                                  TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child:
                                                                          const Text(
                                                                        'Cancelar',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      )),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      )),
                                            ),
                                          ],
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Center(
                                          child: Text(
                                            post['type'],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(thickness: 1),
                      Column(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: IconButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const AddPost()),
                                  );
                                  if (result == true) {
                                    setState(() {
                                      markers.clear();
                                      _checkArrayDeletedPosts();
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                              )),
                          const Text('Add')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isTypeWindowVisible)
            Positioned(
              left: 90,
              top: 30,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isTypeWindowVisible = false;
                  });
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
