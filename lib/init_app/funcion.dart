import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/init_app/ajustes.dart';
import 'package:petwalks_app/init_app/historial.dart';
import 'package:petwalks_app/init_app/open_map.dart';
import 'package:petwalks_app/init_app/red_social.dart';
import 'package:petwalks_app/init_app/servicios.dart';

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
    const RedSocial(),
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
        body: _pages[_pageIndex],
        bottomNavigationBar: ConvexAppBar(
          items: const [
            TabItem(icon: FontAwesomeIcons.mapMarkerAlt, title: 'Mapa'),
            TabItem(icon: FontAwesomeIcons.dog, title: 'Servicios'),
            TabItem(icon: FontAwesomeIcons.history, title: 'Historial'),
            TabItem(icon: FontAwesomeIcons.users, title: 'Red social'),
            TabItem(icon: FontAwesomeIcons.cogs, title: 'Ajustess'),
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
            switch (index) {
              case 0:
                _pages[0];
              case 1:
                _pages[1];
              case 2:
                _pages[2];
              case 3:
                _pages[3];
              case 4:
                _pages[4];
            }
          },
        ),
      ),
    );
  }
}

// class _FuncionState extends State<Funcion> {
//   int _pageIndex = 0;
//   final List<Widget> _pages = [
//     const OpenMap(),
//     const Servicios(),
//     const Historial(),
//     const RedSocial(),
//     const Ajustes(),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           brightness: Brightness.light,
//         ),
//         home: Scaffold(
//           body: _pages[_pageIndex],
//           bottomNavigationBar: BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             selectedItemColor: Colors.black,
//             unselectedItemColor: Colors.black,
//             selectedFontSize: 16.0,
//             unselectedFontSize: 14.0,
//             selectedIconTheme: IconThemeData(size: 28),
//             unselectedIconTheme: IconThemeData(size: 18),
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             backgroundColor: Color.fromRGBO(240, 232, 88, 1),
//             selectedLabelStyle: TextStyle(
//                 fontStyle: FontStyle.italic,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15),
//             unselectedLabelStyle: TextStyle(
//                 fontStyle: FontStyle.italic,
//                 fontWeight: FontWeight.w400,
//                 fontSize: 13),
//             onTap: (index) {
//               setState(() {
//                 _pageIndex = index;
//                 //switch (index) {}
//               });
//             },
//             currentIndex: _pageIndex,
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   FontAwesomeIcons.mapMarkerAlt,
//                 ),
//                 label: "Mapa",
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   FontAwesomeIcons.dog,
//                 ),
//                 label: "Servicios",
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   FontAwesomeIcons.history,
//                 ),
//                 label: "Historial",
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   FontAwesomeIcons.users,
//                 ),
//                 label: "Red social",
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   FontAwesomeIcons.cogs,
//                 ),
//                 label: "Ajustes",
//               ),
//             ],
//           ),
//         ));
//   }
// }