import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/bg.dart';
import 'package:omen/core/myAssets.dart';
import 'package:omen/core/myColors.dart';
import 'package:omen/core/myFonts.dart';
import 'package:omen/core/myTheme.dart';
import 'package:omen/core/router.dart';
import 'package:omen/ui/matches_screen/matches.dart';
import 'package:omen/ui/quran_screen/quran.dart';
import 'package:omen/ui/tasks_screen/tasks.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(false);
  });
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          MyRoutes.tasks: (context) => const Tasks(),
          MyRoutes.matches: (context) => const Matches(),
          MyRoutes.quran: (context) => const Quran(),
        },
        title: 'Flutter Demo',
        theme: AppTheme.dark,
        home: Scaffold(
          extendBodyBehindAppBar: true,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Mycolors.transparent,
                leadingWidth: 350,
                title: Text('Omen App', style: Myfonts.labelLarge),
                centerTitle: true,
                actions: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Mycolors.aurora1,
                    child: Text("JD", style: Myfonts.labelMedium),
                  ),
                  SizedBox(width: 20),
                ],
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 12),
                    Image.asset(Myassets.AppLogo, height: 30, width: 30),
                    SizedBox(width: 12),
                    Text("ForstFlow", style: Myfonts.labelLarge),
                    Spacer(),
                    InkWell(
                      highlightColor: Mycolors.transparent,
                      child: Text("Daily Tasks", style: Myfonts.labelMedium),
                      onTap: () => setState(() {
                        page = 0;
                      }),
                    ),
                    SizedBox(width: 12),
                    InkWell(
                      highlightColor: Mycolors.transparent,
                      child: Text("Matches", style: Myfonts.labelMedium),
                      onTap: () => setState(() {
                        page = 1;
                      }),
                    ),
                    SizedBox(width: 12),
                    InkWell(
                        highlightColor: Mycolors.transparent,
                        child: Text("Werd", style: Myfonts.labelMedium),
                        onTap: () => setState(() {
                              page = 2;
                            })),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: SafeArea(
                  child: Stack(children: [
                    const WinterBackground(),
                    IndexedStack(
                      index: page,
                      children: [
                        Tasks(),
                        Matches(),
                        Quran(),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ));
  }
}
