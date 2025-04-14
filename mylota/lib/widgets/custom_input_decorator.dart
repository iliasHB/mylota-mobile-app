import 'package:flutter/material.dart';

import '../utils/styles.dart';

InputDecoration customInputDecoration({
  required String labelText,
  required String hintText,
  Icon? prefixIcon,
  Icon? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,//[Color(0xFF66C3A7), Color(0xFF2A7F67)],
    hintText: hintText,
    hintStyle: AppStyle.cardfooter.copyWith(fontSize: 12,),
    labelStyle: AppStyle.cardfooter.copyWith(fontSize: 12),
    prefixIcon: prefixIcon ?? const Icon(Icons.email_outlined, color: Color(0xFF2A7F67)),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Color(0xFF2A7F67).withOpacity(0.3),//Colors.purple[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide.none,
    ),
  );
}
