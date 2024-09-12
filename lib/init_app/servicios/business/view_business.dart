import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwalks_app/init_app/servicios/business/business_info.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class ViewBusiness extends StatefulWidget {
  const ViewBusiness({super.key});

  @override
  State<ViewBusiness> createState() => _ViewBusinessState();
}

class _ViewBusinessState extends State<ViewBusiness> {
  Map<String, dynamic> showData = {};
  Map<String, dynamic> infoPet = {};
  late List<String> list = [];

  void _fetchBuilderInfo() async {
    list = await getbusinessIds();
    showData = await fetchBuilderInfoBusiness(list);
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
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
      home: Scaffold(
        body: lang == null
            ? null
            : Column(
                children: [
                  Stack(
                    children: [
                      titleW(
                        title: lang! ? 'Empresas' : 'Business',
                      ),
                      Positioned(
                          left: 30,
                          top: 70,
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.arrow_back_ios,
                                    size: 30, color: Colors.black),
                              ),
                              Text(
                                lang! ? 'Regresar' : 'Back',
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<List<String>>(
                      future: getBusinessByIds(),
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
                          return Center(
                              child: Text(lang!
                                  ? 'No se encontraron empresas'
                                  : 'No business found'));
                        } else {
                          List<String> ids = snapshot.data!;
                          return ListView.builder(
                            itemCount: ids.length,
                            itemBuilder: (context, index) {
                              var id = ids[index];
                              var info = showData[id] ?? {};

                              return lang == null
                                  ? null
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                  barrierColor: Colors.white
                                                      .withOpacity(0.65),
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Color.fromRGBO(244,
                                                              210, 248, .30),
                                                      actions: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20.0,
                                                                  vertical: 50),
                                                          child: Center(
                                                            child: Text(
                                                              lang!
                                                                  ? "¿Estás seguro de querer eliminar este negocio?"
                                                                  : "Are you sure you want to delete this enterprise?",
                                                              style: TextStyle(
                                                                fontSize: 20,
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
                                                                  await deleteBusiness(
                                                                      id);

                                                                  Navigator.pop(
                                                                      context);
                                                                  setState(() {
                                                                    _fetchBuilderInfo();
                                                                  });
                                                                },
                                                                child: Text(lang!
                                                                    ? 'Aceptar'
                                                                    : 'Accept')),
                                                            TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child: Text(lang!
                                                                    ? 'Cancelar'
                                                                    : 'Cancel')),
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
                                                  backgroundImage:
                                                      info['imageUrl'] != null
                                                          ? NetworkImage(
                                                              info['imageUrl'])
                                                          : null,
                                                ),
                                                EmptyBox(w: 10),
                                                Text(info['name'] ??
                                                    (lang!
                                                        ? 'Sin nombre'
                                                        : 'No name')),
                                              ],
                                            ),
                                            EmptyBox(w: 20),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    trailing: GestureDetector(
                                                        child: Icon(Icons
                                                            .chevron_right)),
                                                    onTap: () async {
                                                      var fetchedInfoBusiness =
                                                          await getInfoBusinessById(
                                                              id);
                                                      if (!mounted) {
                                                        Navigator.pop(context);
                                                      }

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              InfoBusiness(
                                                            businessData:
                                                                fetchedInfoBusiness,
                                                            imageUrls: info[
                                                                'imageUrls'],
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
                  ),
                ],
              ),
      ),
    );
  }
}
