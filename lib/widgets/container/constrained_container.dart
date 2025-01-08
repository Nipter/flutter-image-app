import 'package:flutter/material.dart';

const double _DEfAULT_MAX_WIDTH = 600.0;

class ConstrainedContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxHeight;

  const ConstrainedContainer(
      {super.key,
      required this.child,
      this.maxWidth = _DEfAULT_MAX_WIDTH,
      this.maxHeight = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: child,
      ),
    );
  }
}
