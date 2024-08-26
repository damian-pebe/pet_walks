import 'package:flutter/material.dart';

class RedSocial extends StatefulWidget {
  const RedSocial({super.key});

  @override
  State<RedSocial> createState() => _RedSocialState();
}

class _RedSocialState extends State<RedSocial> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold());
  }
}
