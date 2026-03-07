import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/bg.dart';
import 'package:omen/component/profile/user_profile_provider.dart';
import 'package:omen/component/tasks/tasks_provider.dart';
import 'package:omen/core/myAssets.dart';
import 'package:omen/core/myColors.dart';
import 'package:omen/core/myFonts.dart';
import 'package:omen/core/myTheme.dart';
import 'package:omen/core/router.dart';
import 'package:omen/ui/focus_screen/focus.dart';
import 'package:omen/ui/matches_screen/matches.dart';
import 'package:omen/ui/quran_screen/quran.dart';
import 'package:omen/ui/tasks_screen/tasks.dart';
import 'package:omen/ui/focus_screen/focus.dart';
import 'package:omen/component/tasks/tasks_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await initTasksStorage();
  await initUserProfileStorage();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(false);
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        MyRoutes.tasks: (context) => const Tasks(),
        MyRoutes.matches: (context) => const Matches(),
        MyRoutes.quran: (context) => const Quran(),
        MyRoutes.focus: (context) => const FocusScreen(),
      },
      title: 'Omen App',
      theme: AppTheme.dark,
      home: const _EntryFlow(),
    );
  }
}

class _EntryFlow extends ConsumerStatefulWidget {
  const _EntryFlow();

  @override
  ConsumerState<_EntryFlow> createState() => _EntryFlowState();
}

class _EntryFlowState extends ConsumerState<_EntryFlow> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userProfileProvider);

    if (!_splashDone) {
      return const _SplashScreen();
    }

    if (name == null || name.trim().isEmpty) {
      return const _OnboardingScreen();
    }

    return _HomeShell(userName: name);
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WinterBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Mycolors.skyDeep.withOpacity(0.60),
                  Mycolors.skyMid.withOpacity(0.88),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Mycolors.glassBorder, width: 1.2),
                  ),
                  child: Image.asset(Myassets.AppLogo),
                ),
                const SizedBox(height: 20),
                Text('Omen', style: Myfonts.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Plan your day. Focus deeper. Stay consistent.',
                  style: Myfonts.bodyMedium,
                ),
                const SizedBox(height: 26),
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingScreen extends ConsumerStatefulWidget {
  const _OnboardingScreen();

  @override
  ConsumerState<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<_OnboardingScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clean = _nameController.text.trim();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WinterBackground(),
          Center(
            child: Container(
              width: 470,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Mycolors.glassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Mycolors.glassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome 👋', style: Myfonts.headlineLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Let’s make Omen personal. What should we call you?',
                    style: Myfonts.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _save(),
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      hintText: 'e.g. Ahmad',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: clean.isEmpty ? null : _save,
                      child: const Text('Start using Omen'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(userProfileProvider.notifier).setName(name);
  }
}

class _HomeShell extends ConsumerStatefulWidget {
  final String userName;

  const _HomeShell({required this.userName});

  @override
  ConsumerState<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<_HomeShell> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userProfileProvider) ?? widget.userName;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Mycolors.transparent,
            leadingWidth: 420,
            title: Text('Omen App', style: Myfonts.labelLarge),
            centerTitle: true,
            actions: [
              Text('Hello, $name', style: Myfonts.labelMedium),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _editName,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Mycolors.aurora1,
                  child: Text(_initials(name), style: Myfonts.labelMedium),
                ),
              ),
              const SizedBox(width: 20),
            ],
            leading: Row(
              children: [
                const SizedBox(width: 12),
                Image.asset(Myassets.AppLogo, height: 30, width: 30),
                const SizedBox(width: 12),
                Text('ForstFlow', style: Myfonts.labelLarge),
                const Spacer(),
                _TopNavLabel(
                  title: 'Daily Tasks',
                  selected: page == 0,
                  onTap: () => setState(() => page = 0),
                ),
                const SizedBox(width: 12),
                _TopNavLabel(
                  title: 'Matches',
                  selected: page == 1,
                  onTap: () => setState(() => page = 1),
                ),
                const SizedBox(width: 12),
                _TopNavLabel(
                  title: 'Werd',
                  selected: page == 2,
                  onTap: () => setState(() => page = 2),
                ),
                const SizedBox(width: 12),
                _TopNavLabel(
                  title: 'Focus',
                  selected: page == 3,
                  onTap: () => setState(() => page = 3),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: SafeArea(
              child: Stack(
                children: [
                  const WinterBackground(),
                  IndexedStack(
                    index: page,
                    children: const [
                      Tasks(),
                      Matches(),
                      Quran(),
                      FocusScreen(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName() async {
    final current = ref.read(userProfileProvider) ?? '';
    final controller = TextEditingController(text: current);

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit profile name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                ref.read(userProfileProvider.notifier).setName(value);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'.toUpperCase();
  }
}

class _TopNavLabel extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TopNavLabel({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Mycolors.transparent,
      onTap: onTap,
      child: Text(
        title,
        style: (selected ? Myfonts.labelLarge : Myfonts.labelMedium).copyWith(
          color: selected ? Mycolors.textPrimary : Mycolors.textSecondary,
        ),
      ),
    );
  }
}
