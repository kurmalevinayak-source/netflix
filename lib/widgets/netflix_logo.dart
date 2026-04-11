
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NetflixLogo extends StatelessWidget {
  final double height;
  final bool isIconOnly;

  const NetflixLogo({
    super.key,
    this.height = 40,
    this.isIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isIconOnly) {
      // The "N" Icon for the App
      return Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/f/ff/Netflix-new-icon.png',
        height: height,
        errorBuilder: (context, error, stackTrace) => Text(
          'N',
          style: GoogleFonts.bebasNeue(
            color: AppTheme.primaryRed,
            fontSize: height * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // The Full "NETFLIX" Wordmark
    return Image.network(
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Netflix_2015_logo.svg/2560px-Netflix_2015_logo.svg.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Text(
        'NETFLIX',
        style: GoogleFonts.bebasNeue(
          color: AppTheme.primaryRed,
          fontSize: height * 1.1,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
        ),
      ),
    );
  }
}
