import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Manatal logo from https://app.manatal.com/assets/img/manatal-logo.52033228.svg
class ManatalLogo extends StatelessWidget {
  const ManatalLogo({
    super.key,
    this.size = 48,
    this.semanticLabel = 'Manatal',
  });

  final double size;
  final String semanticLabel;

  static const assetPath = 'assets/manatal-logo.svg';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
