import 'package:flutter/material.dart';
import 'package:omen/component/bg.dart';
import 'package:omen/core/myAssets.dart';
import 'package:omen/ui/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //   useMaterial3: true,
        // ),
        home: Scaffold(
          // appBar: AppBar(
          //   title: const Text('Omen'),
          //   backgroundColor: Colors.transparent,
          // ),
          body: Stack(children: [
            const WinterBackground(),
            Home(),
            // seeeeeeeeeee
          ]),
        ));
  }
}
