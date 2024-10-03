// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/init_app/ajustes/pets/pet_info.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';

class ViewPets extends StatefulWidget {
  const ViewPets({super.key});

  @override
  State<ViewPets> createState() => _ViewPetsState();
}

class _ViewPetsState extends State<ViewPets> {
  Map<String, dynamic> showData = {};
  Map<String, dynamic> infoPet = {};
  late List<String> list = [];

  void _fetchBuilderInfo() async {
    list = await getPets(email!);
    showData = await fetchBuilderInfo(list);
    setState(() {});
  }

  String? email;
  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {}
    _fetchBuilderInfo();
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<String>>(
        future: getPets(email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    lang! ? 'No se encontraron mascotas' : 'No pets found'));
          } else {
            List<String> ids = snapshot.data!;
            return ListView.builder(
              itemCount: ids.length,
              itemBuilder: (context, index) {
                var id = ids[index];
                var petInfo = showData[id] ?? {};

                return lang == null
                    ? const Center(
                        child: SpinKitSpinningLines(
                            color: Color.fromRGBO(169, 200, 149, 1),
                            size: 50.0))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const EmptyBox(w: 10),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                  size: 35,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierColor:
                                        Colors.white.withOpacity(0.65),
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: const Color.fromARGB(
                                            159, 229, 248, 210),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0, vertical: 50),
                                            child: Center(
                                              child: Text(
                                                lang!
                                                    ? "¿Estás seguro de querer eliminar a la mascota?"
                                                    : "Are you sure you want to delete the pet?",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              TextButton(
                                                  onPressed: () async {
                                                    await deletePet(id, email!);

                                                    Navigator.pop(context);
                                                    setState(() {
                                                      _fetchBuilderInfo();
                                                    });
                                                  },
                                                  child: Text(
                                                    lang!
                                                        ? 'Aceptar'
                                                        : 'Accept',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  )),
                                              TextButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    lang!
                                                        ? 'Cancelar'
                                                        : 'Cancel',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    ),
                                                  )),
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              const EmptyBox(w: 10),
                              const VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: petInfo['imageUrl'] != null
                                        ? NetworkImage(petInfo['imageUrl'])
                                        : null,
                                  ),
                                  const EmptyBox(w: 10),
                                  Text(petInfo['name'] ??
                                      (lang! ? 'Sin nombre' : 'No name')),
                                ],
                              ),
                              const EmptyBox(w: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    ListTile(
                                      trailing: GestureDetector(
                                          child:
                                              const Icon(Icons.chevron_right)),
                                      onTap: () async {
                                        var fetchedInfoPet =
                                            await getInfoPets(email!, id);
                                        if (!mounted) {
                                          Navigator.pop(context);
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => InfoPet(
                                              petData: fetchedInfoPet,
                                              imageUrls: petInfo['imageUrls'],
                                              id: id,
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          _fetchBuilderInfo();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
              },
            );
          }
        },
      ),
    );
  }
}
