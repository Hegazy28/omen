import 'package:flutter/material.dart';
import 'package:omen/core/myAssets.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [Image.asset(Myassets.AppLogo, height: 50, width: 50)],
        )
      ],
    );
  }
}
