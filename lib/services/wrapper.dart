import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/init_app/function.dart';
import 'package:petwalks_app/pages/opciones/options.dart';
import 'package:petwalks_app/services/firebase_tracker.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SpinKitSpinningLines(
                      color: Color.fromRGBO(169, 200, 149, 1), size: 50.0),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('error'),
                );
              } else {
                if (snapshot.data == null) {
                  return const Opciones();
                } else {
                  checkUserAndStartTracking(); //?this got to look for aanother place aas well

                  return const Funcion();
                }
              }
            })));
  }
}
