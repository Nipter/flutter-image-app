import 'package:flutter/material.dart';

class ShadowContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const ShadowContainer(
      {super.key, required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
            offset: const Offset(5, 5),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.35),
            offset: const Offset(-5, -5),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
