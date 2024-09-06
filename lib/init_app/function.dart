import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/configuration.dart';
import 'package:petwalks_app/init_app/history.dart';
import 'package:petwalks_app/init_app/open_map.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_requests.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_start_walk.dart';
import 'package:petwalks_app/init_app/social_network.dart';
import 'package:petwalks_app/init_app/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:petwalks_app/widgets/decorations.dart';

class Funcion extends StatefulWidget {
  const Funcion({super.key});

  @override
  State<Funcion> createState() => _FuncionState();
}

class _FuncionState extends State<Funcion> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    const OpenMap(),
    const Servicios(),
    const Historial(),
    const SocialNetwork(),
    const Ajustes(),
  ];
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        home: Scaffold(
          body: Stack(
            children: [
              _pages[_pageIndex],
              if (visible)
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PendingRequestsNotifications(),
                      StartWalkManagement(),
                      //endwalk
                    ],
                  ),
                ),
              if (_pageIndex == 2)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      visible = !visible;
                    }),
                    style: customOutlinedButtonStyle(),
                    child: Column(
                      children: [
                        Icon(
                          visible
                              ? FontAwesomeIcons.windowClose
                              : FontAwesomeIcons.windowRestore,
                          color: Colors.black,
                        ),
                        const Text('Solicitudes',
                            style: TextStyle(fontSize: 8, color: Colors.black))
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: ConvexAppBar(
            items: const [
              TabItem(icon: FontAwesomeIcons.mapMarkerAlt, title: 'Mapa'),
              TabItem(icon: FontAwesomeIcons.dog, title: 'Servicios'),
              TabItem(icon: FontAwesomeIcons.history, title: 'Historial'),
              TabItem(icon: FontAwesomeIcons.users, title: 'Red social'),
              TabItem(icon: FontAwesomeIcons.cogs, title: 'Ajustes'),
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
      ),
    );
  }
}
