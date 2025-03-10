import 'package:flutter/material.dart';

class WatchProgressBar extends StatelessWidget {
  final int progress;
  final double height;
  final Color progressColor;
  final Color backgroundColor;

  const WatchProgressBar({
    Key? key,
    required this.progress,
    this.height = 6.0,
    this.progressColor = const Color(0xFFE21221),
    this.backgroundColor = const Color(0xFF3A3A3A),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress / 100,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: progressColor.withOpacity(0.5),
                blurRadius: 4.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
