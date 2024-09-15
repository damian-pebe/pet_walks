import 'package:flutter/material.dart';

class Premium extends StatelessWidget {
  const Premium({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromRGBO(250, 244, 229, 1),
        ),
        home: Scaffold(
          body: Center(
            child:
                OutlinedButton(onPressed: () {}, child: Text('payment method')),
          ),
        ));
  }
}
