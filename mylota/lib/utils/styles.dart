import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static TextStyle headerTitle = GoogleFonts.nobile(
    //color: tertiaryGrey,
      fontSize: 12,
      fontWeight: FontWeight.w600
  );

  static TextStyle secondaryText = GoogleFonts.almendra(
    //color: tertiaryWhite,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle tertiaryText = GoogleFonts.alice(
    //color: tertiaryGrey,
      fontSize: 12,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400
  );

  static TextStyle tertiaryText_ext = tertiaryText.copyWith(
    //color: secondaryPurple
  );

  static TextStyle pageTitle = GoogleFonts.poppins(
      // color: primaryGreen,
      fontSize: 16,
      fontWeight: FontWeight.w600
  );

  static TextStyle cardTitle = GoogleFonts.poppins(
    //color: tertiaryWhite,
      fontSize: 18,
      fontWeight: FontWeight.w600
  );

  static TextStyle cardSubtitle = GoogleFonts.poppins(
    //color: tertiaryWhite,
      fontSize: 16,
      fontWeight: FontWeight.w600
  );

  static TextStyle cardSubtitle_ext = cardSubtitle.copyWith(
      fontWeight: FontWeight.normal
  );

  static TextStyle cardfooter = GoogleFonts.poppins(
    //color: tertiaryWhite,
      fontSize: 14,
      fontWeight: FontWeight.w400
  );

// static TextStyle hea = GoogleFonts.poppins(
//   //color: tertiaryGrey,
//     fontSize: getFontSize(12),
//     fontWeight: FontWeight.w600
// );

}