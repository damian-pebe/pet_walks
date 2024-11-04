import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/configuration.dart';
import 'package:petwalks_app/init_app/history.dart';
import 'package:petwalks_app/init_app/open_map.dart';
import 'package:petwalks_app/init_app/social_network.dart';
import 'package:petwalks_app/init_app/services.dart';
import 'package:petwalks_app/services/firebase_services.dart';

class Funcion extends StatefulWidget {
  final int? index;
  const Funcion({this.index, super.key});

  @override
  State<Funcion> createState() => _FuncionState();
}

class _FuncionState extends State<Funcion> {
  @override
  void initState() {
    super.initState();
    _getLanguage();
    index();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    if (mounted) setState(() {});
    await getAndAddTokenToArray();
  }

  index() {
    if (widget.index != null) {
      setState(() {
        _pageIndex = widget.index!;
      });
    }
  }

  int _pageIndex = 0;
  final List<Widget> _pages = [
    const OpenMap(),
    const Servicios(),
    const Historial(),
    const SocialNetwork(),
    const Ajustes(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: Scaffold(
        body: lang == null
            ? const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
            : Stack(
                children: [
                  _pages[_pageIndex],
                ],
              ),
        bottomNavigationBar: lang == null
            ? const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
            : ConvexAppBar(
                items: [
                  TabItem(
                    icon: FontAwesomeIcons.mapMarkerAlt,
                    title: lang! ? 'Mapa' : 'Open map',
                  ),
                  TabItem(
                    icon: FontAwesomeIcons.dog,
                    title: lang! ? 'Servicios' : 'Services',
                  ),
                  TabItem(
                    icon: FontAwesomeIcons.history,
                    title: lang! ? 'Historial' : 'History',
                  ),
                  TabItem(
                    icon: FontAwesomeIcons.users,
                    title: lang! ? 'Comunidad' : 'Community',
                  ),
                  TabItem(
                    icon: FontAwesomeIcons.cogs,
                    title: lang! ? 'Ajustes' : 'Settings',
                  ),
                ],
                color: Colors.grey,
                activeColor: Colors.black,
                backgroundColor: Colors.yellow[200],
                shadowColor: Colors.black.withOpacity(0.3),
                height: 70,
                curveSize: 80,
                top: -20,
                elevation: 30,
                style: TabStyle.reactCircle,
                initialActiveIndex: _pageIndex,
                onTap: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
              ),
      ),
    );
  }
}
