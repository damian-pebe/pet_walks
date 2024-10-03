// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

InputDecoration StyleTextField(String text) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: Colors.black, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(color: Colors.black, width: 2.0),
    ),
    hintText: text,
    hintStyle: TextStyle(
      color: Colors.grey[600],
      fontSize: 18.0,
      fontStyle: FontStyle.italic,
    ),
    labelText: text,
    labelStyle: TextStyle(
      color: Colors.grey[600],
      fontSize: 18.0,
      fontStyle: FontStyle.italic,
    ),
    focusColor: Colors.transparent,
  );
}

ButtonStyle customOutlinedButtonStyle() {
  return OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
      side: const BorderSide(width: 2.0, color: Colors.black),
    ),
    backgroundColor: Colors.grey[200],
  );
}

ButtonStyle customOutlinedButtonStyleYellow() {
  return OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    backgroundColor: Colors.yellow[100],
  );
}

ButtonStyle customOutlinedButtonStyleGreen() {
  return OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    backgroundColor: const Color.fromRGBO(169, 200, 149, 1),
  );
}

Container containerStyle(String msg) {
  return Container(
    width: 300.0,
    height: 60.0,
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      border: Border.all(
        color: Colors.grey,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Text(
      msg,
      style: const TextStyle(
        fontSize: 16.0,
        color: Colors.black,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 2.0,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

Container containerStyleDescription(String msg) {
  return Container(
    constraints: const BoxConstraints(maxHeight: 150.0, maxWidth: 300),
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      border: Border.all(
        color: Colors.grey,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150.0, maxWidth: 300),
      child: SingleChildScrollView(
        child: Text(
          msg,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
