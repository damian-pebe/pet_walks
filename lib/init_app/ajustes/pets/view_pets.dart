import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    } else {
      print('Error getting email from user');
    }
    _fetchBuilderInfo();
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<String>>(
        future: getPets(email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pets found'));
          } else {
            List<String> ids = snapshot.data!;
            return ListView.builder(
              itemCount: ids.length,
              itemBuilder: (context, index) {
                var id = ids[index];
                var petInfo = showData[id] ?? {};

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        EmptyBox(w: 10),
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
                              barrierColor: Colors.white.withOpacity(0.65),
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Color.fromRGBO(244, 210, 248, .30),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 50),
                                      child: Center(
                                        child: Text(
                                          "¿Estas seguro de querer eliminar a la mascota?",
                                          style: TextStyle(
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
                                            child: Text('Aceptar')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancelar')),
                                      ],
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        EmptyBox(w: 10),
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
                            EmptyBox(w: 10),
                            Text(petInfo['name'] ?? 'No name'),
                          ],
                        ),
                        EmptyBox(w: 20),
                        Expanded(
                          child: Column(
                            children: [
                              ListTile(
                                trailing: GestureDetector(
                                    child: Icon(Icons.chevron_right)),
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
