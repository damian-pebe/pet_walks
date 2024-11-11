// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches, deprecated_member_use
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petwalks_app/env.dart';
import 'package:petwalks_app/init_app/servicios/add_post.dart';
import 'package:petwalks_app/init_app/servicios/markers_details/social_details.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/utils/constans.dart';
import 'package:petwalks_app/widgets/toast.dart';

class SocialNetwork extends StatefulWidget {
  const SocialNetwork({super.key});

  @override
  State<SocialNetwork> createState() => _SocialNetwork();
}

class _SocialNetwork extends State<SocialNetwork> {
  late latLng.LatLng _center;

  Marker? selectedMarker;
  map.LatLng? selectedPosition;
  String? domicilio;
  bool _isPermissionGranted = false;
  List<Marker> markers = [];
  var showData;

  Future<void> _getPosts(Set<Map<String, dynamic>> idsAddress) async {
    if (idsAddress.isNotEmpty) {
      String addressToCheck = idsAddress.first['address'];
      bool premium = idsAddress.first['premium'];
      String type = idsAddress.first['type'];

      List<String> idsWithSameAddress = [];
      if (filterType == '') {
        for (var element in idsAddress) {
          if (element['address'] == addressToCheck) {
            idsWithSameAddress.add(element['id']);
          }
        }
      } else {
        for (var element in idsAddress) {
          if (element['address'] == addressToCheck && type == filterType) {
            idsWithSameAddress.add(element['id']);
          }
        }
      }
      idsAddress.removeWhere((element) => element['address'] == addressToCheck);
      _addMarker(idsWithSameAddress, addressToCheck, premium);
      if (idsAddress.isNotEmpty) {
        await _getPosts(idsAddress);
      }
    }
  }

  Future<void> _addMarker(List<String> idsWithSameAddress,
      String addressToCheck, bool premium) async {
    map.LatLng? position = await getLatLngFromAddress(addressToCheck);

    if (position != null && idsWithSameAddress.isNotEmpty) {
      latLng.LatLng latLngPosition =
          latLng.LatLng(position.latitude, position.longitude);

      String assetPath = premium ? businessMarkerDeluxe : businessMarker;

      markers.add(Marker(
          point: latLngPosition,
          width: 80,
          height: 80,
          child: TextButton(
            child: Image.asset(
              assetPath,
              width: 80,
              height: 80,
            ),
            onPressed: () {
              _showBottomSheet(postIds: idsWithSameAddress);
            },
          )));
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

    _checkLocationPermission();
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
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _center = latLng.LatLng(position.latitude, position.longitude);
        _isPermissionGranted = true;
      });
    }
  }

  bool _isTypeWindowVisible = false;

  String filterType = "";

  dialog() {
    showModalBottomSheet(
      backgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                lang! ? 'Filtrar publicaciones' : 'Filter posts',
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
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          filterType = "Extravio";
                        });

                        Navigator.pop(context);
                        dialog();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: filterType == "Extravio"
                              ? Colors.black
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Extravio',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          filterType = "Adopcion";
                        });
                        Navigator.pop(context);
                        dialog();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: filterType == "Adopcion"
                              ? Colors.black
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Adopcion',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        markers.clear();
                        _arrayPost();
                        setState(() {});
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
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () {
                    filterType = "";

                    Navigator.pop(context);
                    dialog();
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
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const navbarHeight = kBottomNavigationBarHeight;

    return Scaffold(
      body: lang == null
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
          : Stack(
              children: [
                if (_isPermissionGranted)
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
                  )
                else
                  const Center(
                      child: SpinKitSpinningLines(
                          color: Color.fromRGBO(169, 200, 149, 1), size: 50.0)),
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
                                      child: SpinKitSpinningLines(
                                          color:
                                              Color.fromRGBO(169, 200, 149, 1),
                                          size: 50.0));
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
                                                      backgroundImage:
                                                          NetworkImage(
                                                              post['imageUrls']
                                                                  [0]),
                                                    ),
                                                    onTap: () =>
                                                        _showBottomSheetAlone(
                                                            postIds: [
                                                          post['id']
                                                        ]),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3),
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
                                                                  .withOpacity(
                                                                      0.65),
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      const Color
                                                                          .fromARGB(
                                                                          159,
                                                                          229,
                                                                          248,
                                                                          210),
                                                                  actions: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10.0,
                                                                          vertical:
                                                                              50),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          lang!
                                                                              ? '¿Estas seguro de querer eliminar el post?'
                                                                              : 'Do you really want to delete the post?',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              await deletePost(post['id']);

                                                                              setState(() {
                                                                                toastF(
                                                                                  lang! ? 'Publicacion eliminada' : 'Post deleted',
                                                                                );
                                                                              });
                                                                              // ignore: use_build_context_synchronously
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              lang! ? 'Aceptar' : 'Accept',
                                                                              style: const TextStyle(
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: Colors.black,
                                                                              ),
                                                                            )),
                                                                        TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context),
                                                                            child: Text(
                                                                              lang! ? 'Cancelar' : 'Cancel',
                                                                              style: const TextStyle(
                                                                                fontSize: 20,
                                                                                fontWeight: FontWeight.w900,
                                                                                color: Colors.black,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Center(
                                                child: Text(
                                                  post['type'] == 'Extravio'
                                                      ? (lang!
                                                          ? 'Extravio'
                                                          : 'Stray')
                                                      : (lang!
                                                          ? 'Adopcion'
                                                          : 'Adoption'),
                                                  style: const TextStyle(
                                                      fontSize: 12),
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
                                              builder: (context) =>
                                                  const AddPost()),
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
                        dialog();
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
