import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petwalks_app/pages/opciones/sign_up.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class BlurScreenHistory extends StatefulWidget {
  const BlurScreenHistory({super.key});

  @override
  State<BlurScreenHistory> createState() => _BlurScreenState();
}

class _BlurScreenState extends State<BlurScreenHistory> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Scaffold(
          body: Stack(
            children: [
              const HistoryBlur(),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Sign_Up(),
                    ),
                  ),
                  child: const Text('Iniciar sesion para continuar',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          color: Colors.black)),
                ),
              )
            ],
          ),
        ));
  }
}

class HistoryBlur extends StatefulWidget {
  const HistoryBlur({super.key});

  @override
  State<HistoryBlur> createState() => _HistorialState();
}

class _HistorialState extends State<HistoryBlur> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      body: Column(
        children: [
          Stack(
            children: [
              const titleW(title: 'History'),
              Positioned(
                  left: 330,
                  top: 70,
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swipe_right,
                            size: 30, color: Colors.black),
                        onPressed: () {},
                      ),
                      const Text(
                        'Request',
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
