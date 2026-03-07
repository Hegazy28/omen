import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/focus/focus_provider.dart';
import 'package:omen/core/myColors.dart';
import 'package:omen/core/myFonts.dart';

class FocusWidget extends ConsumerWidget {
  const FocusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusSessionProvider);
    final notifier = ref.read(focusSessionProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Focus Mode', style: Myfonts.headlineLarge),
        const SizedBox(height: 6),
        Text(
          'Pomodoro flow with automatic breaks and session stats.',
          style: Myfonts.bodySmall,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _TimerCard(state: state),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _ControlPanel(state: state, notifier: notifier),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerCard extends StatelessWidget {
  final FocusSessionState state;

  const _TimerCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final mm = (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (state.remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      decoration: _glass(),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_phaseTitle(state.phase), style: Myfonts.headlineMedium),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: state.progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation(Mycolors.primary),
                ),
                Center(
                  child: Text('$mm:$ss', style: Myfonts.monoLarge.copyWith(fontSize: 42)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(_phaseHint(state.phase), style: Myfonts.bodyMedium),
        ],
      ),
    );
  }
}

class _ControlPanel extends ConsumerWidget {
  final FocusSessionState state;
  final FocusSessionNotifier notifier;

  const _ControlPanel({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = ref.watch(focusIntentProvider);

    return Container(
      decoration: _glass(),
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: notifier.toggleRun,
                  icon: Icon(state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  label: Text(state.isRunning ? 'Pause' : 'Start'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: notifier.resetCurrentPhase,
                icon: const Icon(Icons.replay_rounded),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: notifier.skipPhase,
                icon: const Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Today', style: Myfonts.labelLarge),
          const SizedBox(height: 6),
          _stat('Completed focus blocks', '${state.completedFocusSessions}'),
          _stat('Current cycle', '${(state.cycleIndex % 4) + 1} / 4'),
          const Divider(height: 24),
          Text('Session Intent', style: Myfonts.labelLarge),
          const SizedBox(height: 8),
          TextField(
            maxLines: 2,
            onChanged: (value) => ref.read(focusIntentProvider.notifier).state = value,
            decoration: const InputDecoration(
              hintText: 'What are you working on in this session?',
            ),
          ),
          if (intent.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Intent: ${intent.trim()}', style: Myfonts.caption),
          ],
          const Divider(height: 24),
          Text('Timer Settings', style: Myfonts.labelLarge),
          const SizedBox(height: 8),
          _DurationStepper(
            label: 'Focus',
            minutes: state.focusMinutes,
            onChanged: (m) => notifier.updateDurations(focusMinutes: m),
          ),
          _DurationStepper(
            label: 'Short break',
            minutes: state.shortBreakMinutes,
            onChanged: (m) => notifier.updateDurations(shortBreakMinutes: m),
          ),
          _DurationStepper(
            label: 'Long break',
            minutes: state.longBreakMinutes,
            onChanged: (m) => notifier.updateDurations(longBreakMinutes: m),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Myfonts.bodySmall)),
          Text(value, style: Myfonts.monoSmall),
        ],
      ),
    );
  }
}

class _DurationStepper extends StatelessWidget {
  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

  const _DurationStepper({
    required this.label,
    required this.minutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Myfonts.bodySmall)),
          IconButton(
            onPressed: minutes > 1 ? () => onChanged(minutes - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
          ),
          Text('$minutes min', style: Myfonts.monoSmall),
          IconButton(
            onPressed: minutes < 90 ? () => onChanged(minutes + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

String _phaseTitle(FocusPhase phase) {
  return switch (phase) {
    FocusPhase.focus => 'Deep Focus',
    FocusPhase.shortBreak => 'Short Break',
    FocusPhase.longBreak => 'Long Break',
  };
}

String _phaseHint(FocusPhase phase) {
  return switch (phase) {
    FocusPhase.focus => 'Silence distractions and complete one important chunk.',
    FocusPhase.shortBreak => 'Stand up, hydrate, breathe for a minute.',
    FocusPhase.longBreak => 'Reset your energy before the next sprint.',
  };
}

BoxDecoration _glass() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    color: Mycolors.glassWhite,
    border: Border.all(color: Mycolors.glassBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.14),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
