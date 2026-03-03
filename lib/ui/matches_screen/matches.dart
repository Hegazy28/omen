import 'package:flutter/material.dart';
import 'package:omen/component/matches/matches_widget.dart';

class Matches extends StatelessWidget {
  const Matches({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      child: MatchesWidget(),
    );
  }
}
