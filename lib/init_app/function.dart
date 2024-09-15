import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/configuration.dart';
import 'package:petwalks_app/init_app/history.dart';
import 'package:petwalks_app/init_app/open_map.dart';
import 'package:petwalks_app/init_app/social_network.dart';
import 'package:petwalks_app/init_app/services.dart';
import 'package:petwalks_app/services/firebase_services.dart';

class Funcion extends StatefulWidget {
  const Funcion({super.key});

  @override
  State<Funcion> createState() => _FuncionState();
}

class _FuncionState extends State<Funcion> {
  @override
  void initState() {
    super.initState();
    print('funcion language');
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    if (mounted) setState(() {});
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
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  _pages[_pageIndex],
                ],
              ),
        bottomNavigationBar: lang == null
            ? null
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
