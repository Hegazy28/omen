import 'package:flutter/material.dart';
import 'package:omen/component/bg.dart';
import 'package:omen/core/myTheme.dart';
import 'package:omen/ui/home.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.maximize(); // opens app in full-screen
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
    await windowManager.setResizable(false);
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
        theme: AppTheme.dark,
        home: Scaffold(
          body: Stack(children: [
            const WinterBackground(),
            Home(),
          ]),
        ));
  }
}
