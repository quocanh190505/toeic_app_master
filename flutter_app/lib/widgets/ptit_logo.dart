import 'package:flutter/material.dart';

class PtitLogo extends StatelessWidget {
  final double width;
  final bool showSubtitle;

  const PtitLogo({
    super.key,
    this.width = 150,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'image/logo.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
