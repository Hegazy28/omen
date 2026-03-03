import 'package:flutter/material.dart';
import 'package:omen/component/quran/quran_widget.dart';

class Quran extends StatelessWidget {
  const Quran({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      child: QuranWidget(),
    );
  }
}
