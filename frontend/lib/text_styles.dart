import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static final title = GoogleFonts.nunitoSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final subtitle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold
  );

  static final body = const TextStyle(
      fontSize: 15
  );

  static final button = GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}