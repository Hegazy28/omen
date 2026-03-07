import 'package:flutter/material.dart';
import 'package:omen/component/focus/focus_widget.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        child: SizedBox(
          width: double.infinity,
          height: 460,
          child: const FocusWidget(),
        ),
      ),
    );
  }
}
