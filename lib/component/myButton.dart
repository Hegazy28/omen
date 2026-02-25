import 'package:flutter/material.dart';
import 'package:omen/core/myAssets.dart';
import 'package:omen/core/myColors.dart';
import 'package:omen/core/myFonts.dart';

class Mybutton extends StatelessWidget {
  const Mybutton(
      {required this.onPressed,
      required this.text,
      required this.imageString,
      super.key});

  final VoidCallback onPressed;
  final String text;

  final String imageString;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(140, 36)),
            backgroundColor: WidgetStateProperty.all(Mycolors.transparent),
            foregroundColor: WidgetStateProperty.all(Mycolors.textPrimary),
            textStyle: WidgetStateProperty.all(Myfonts.bodyMedium),
            overlayColor: WidgetStateProperty.all(Mycolors.primaryGlow),
            shadowColor: WidgetStatePropertyAll(Mycolors.transparent),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Mycolors.glassBorder, width: 1))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                imageString,
                height: 24,
                width: 24,
                color: Mycolors.textPrimary,
              ),
              //Icon,
              SizedBox(width: 8),
              Text(text),
            ],
          )),
    );
  }
}
