import 'package:flutter/material.dart';

class VisibilityW extends StatefulWidget {
  final bool boolean;
  final String string;
  const VisibilityW({required this.boolean, required this.string, super.key});

  @override
  State<VisibilityW> createState() => _VisibilityWState();
}

class _VisibilityWState extends State<VisibilityW> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !widget.boolean,
      child: Text(
        "* ${widget.string}",
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
    );
  }
}
