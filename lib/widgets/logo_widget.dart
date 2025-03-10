import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double height;
  final double? width;
  
  const LogoWidget({
    Key? key,
    this.height = 40,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/images/logo.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}
