import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String label;
  final FontWeight? fontWeight;
  final double fontSize;

  const CustomText({Key? key, required this.label, this.fontWeight, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
        label,
      style: GoogleFonts.aboreto(
        fontWeight: fontWeight,
        fontSize: fontSize
      ),
    );
  }
}
