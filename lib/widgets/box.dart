import 'package:flutter/material.dart';

class EmptyBox extends StatelessWidget {
  final double? w;
  final double? h;

  const EmptyBox({this.w, this.h, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: w ?? 0, height: h ?? 0);
  }
}
