import 'package:flutter/material.dart';

class VibratingContainer extends StatefulWidget {
  final Widget child;

  const VibratingContainer({super.key, required this.child});

  @override
  // ignore: library_private_types_in_public_api
  _VibratingContainerState createState() => _VibratingContainerState();
}

class _VibratingContainerState extends State<VibratingContainer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(_controller!);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation!.value, 0),
          child: widget.child,
        );
      },
    );
  }
}
