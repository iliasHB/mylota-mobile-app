
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/styles.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final double borderRadius;

  const CustomPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
    this.textStyle,
    this.borderRadius = 10.0, required Text child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF2A7F67), // Default here
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Text(
            label,
            style: textStyle ?? AppStyle.cardSubtitle.copyWith(color: Colors.white, fontSize: 14)
        ),
      ),
    );
  }
}
///

class CustomSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  // final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final double borderRadius;
  final signup;

  const CustomSecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    // this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
    this.textStyle,
    this.borderRadius = 10.0, this.signup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF2A7F67)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Text(
            label,
            style: textStyle
                ?? AppStyle.cardSubtitle.copyWith(color: signup != 1 ? const Color(0xFF2A7F67) : Colors.white, fontSize: 14)
        ),
      ),
    );
  }
}


class CustomLoadingButton extends StatelessWidget {

  const CustomLoadingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[500], // Default here
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: const SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2.0, // Adjust the thickness
          color: Colors.white, // Optional: Change the color to match your theme
        ),
      ),
    );
  }
}


class CustomContainerLoadingButton extends StatelessWidget {
  const CustomContainerLoadingButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        height: 25,
        width: 25,
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(50)
        ),

        child: const CircularProgressIndicator(
          strokeWidth: 2.0, // Adjust the thickness
          color: Colors.white, // Optional: Change the color to match your theme
        ),
      ),
    );
  }
}



