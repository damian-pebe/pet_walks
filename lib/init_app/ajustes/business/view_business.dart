import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/init_app/ajustes/business/business_info.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class ViewBusiness extends StatefulWidget {
  const ViewBusiness({super.key});

  @override
  State<ViewBusiness> createState() => _ViewBusinessState();
}

class _ViewBusinessState extends State<ViewBusiness> {
  bool? lang;
  late Future<Map<String, dynamic>> _businessDataFuture;

  @override
  void initState() {
    super.initState();
    _getLanguage();
  }

  Future<void> _getLanguage() async {
    lang = await getLanguage();
    setState(() {
      _businessDataFuture = _fetchAllBusinessData();
    });
  }

  Future<Map<String, dynamic>> _fetchAllBusinessData() async {
    List<String> ids = await getBusinessByIds();
    return fetchBuilderInfoBusiness(ids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lang == null
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
          : FutureBuilder<Map<String, dynamic>>(
              future: _businessDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: SpinKitSpinningLines(
                          color: Color.fromRGBO(169, 200, 149, 1), size: 50.0));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(lang!
                          ? 'No se encontraron empresas'
                          : 'No business found'));
                } else {
                  Map<String, dynamic> businessData = snapshot.data!;
                  List<String> ids = businessData.keys.toList();

                  return ListView.builder(
                    itemCount: ids.length,
                    itemBuilder: (context, index) {
                      var id = ids[index];
                      var info = businessData[id] ?? {};

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const EmptyBox(w: 10),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.black, size: 35),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierColor: Colors.white.withOpacity(0.65),
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Color.fromARGB(159, 229, 248, 210),
                                    actions: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 50),
                                        child: Center(
                                          child: Text(
                                            lang!
                                                ? "¿Estás seguro de querer eliminar este negocio?"
                                                : "Are you sure you want to delete this enterprise?",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              await deleteBusiness(id);
                                              Navigator.pop(context);
                                              setState(() {});
                                            },
                                            child: Text(
                                                lang! ? 'Aceptar' : 'Accept'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                                lang! ? 'Cancelar' : 'Cancel'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          EmptyBox(w: 10),
                          const VerticalDivider(
                              width: 1, thickness: 1, color: Colors.black),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: info['imageUrl'] != null
                                ? NetworkImage(info['imageUrl'])
                                : null,
                          ),
                          EmptyBox(w: 10),
                          Text(info['name'] ??
                              (lang! ? 'Sin nombre' : 'No name')),
                          EmptyBox(w: 20),
                          IconButton(
                              onPressed: () {
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InfoBusiness(
                                      imageUrls: info['imageUrls'],
                                      id: id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward_ios))
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

class Business extends StatefulWidget {
  const Business({super.key});

  @override
  State<Business> createState() => _BusinessState();
}

class _BusinessState extends State<Business> {
  bool? lang;

  @override
  void initState() {
    super.initState();
    _getLanguage();
  }

  Future<void> _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1),
        ),
        home: Scaffold(
          body: lang == null
              ? const Center(
                  child: SpinKitSpinningLines(
                      color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        titleW(title: lang! ? 'Empresas' : 'Business'),
                        Positioned(
                          left: 30,
                          top: 70,
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back_ios,
                                    size: 30, color: Colors.black),
                              ),
                              Text(
                                lang! ? 'Regresar' : 'Back',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Expanded(
                        child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: ViewBusiness(),
                    )),
                  ],
                ),
        ));
  }
}
