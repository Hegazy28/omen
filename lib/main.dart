import 'package:flutter/material.dart';
import 'package:omen/component/bg.dart';
import 'package:omen/core/myAssets.dart';
import 'package:omen/ui/home.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setResizable(false);
    //await windowManager.setMinimumSize(const Size(1000, 700));
  });
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
          //   elevation: 0,
          //   foregroundColor: Colors.red,
          // ),
          body: Stack(children: [
            const WinterBackground(),
            Home(),
          ]),
        ));
  }
}
