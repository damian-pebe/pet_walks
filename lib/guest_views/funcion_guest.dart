import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petwalks_app/guest_views/blur_screen_community.dart';
import 'package:petwalks_app/guest_views/blur_screen_history.dart';
import 'package:petwalks_app/guest_views/blur_screen_services.dart';
import 'package:petwalks_app/guest_views/blur_screen_settings.dart';
import 'package:petwalks_app/guest_views/guest_map.dart';

class FuncionGuest extends StatefulWidget {
  const FuncionGuest({super.key});

  @override
  State<FuncionGuest> createState() => _FuncionGuestState();
}

class _FuncionGuestState extends State<FuncionGuest> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    const OpenMapGuest(),
    const BlurScreenServices(),
    const BlurScreenHistory(),
    const BlurScreenPosts(),
    const BlurScreenSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            _pages[_pageIndex],
          ],
        ),
        bottomNavigationBar: ConvexAppBar(
          items: const [
            TabItem(
              icon: FontAwesomeIcons.mapMarkerAlt,
              title: 'Open map',
            ),
            TabItem(
              icon: FontAwesomeIcons.dog,
              title: 'Services',
            ),
            TabItem(
              icon: FontAwesomeIcons.history,
              title: 'History',
            ),
            TabItem(
              icon: FontAwesomeIcons.users,
              title: 'Community',
            ),
            TabItem(
              icon: FontAwesomeIcons.cogs,
              title: 'Settings',
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
