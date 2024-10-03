import 'package:flutter/material.dart';

class ViewChats extends StatefulWidget {
  const ViewChats({super.key});

  @override
  State<ViewChats> createState() => _ViewChatsState();
}

class _ViewChatsState extends State<ViewChats> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: const Scaffold());
  }
}
