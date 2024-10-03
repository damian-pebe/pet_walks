// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';

class titleW extends StatelessWidget {
  final String title;

  const titleW({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(169, 200, 149, 1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
