import 'package:flutter/material.dart';

class VibratingContainer extends StatefulWidget {
  final Widget child;

  const VibratingContainer({Key? key, required this.child}) : super(key: key);

  @override
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
