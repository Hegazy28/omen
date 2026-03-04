import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusPhase { focus, shortBreak, longBreak }

class FocusSessionState {
  final FocusPhase phase;
  final bool isRunning;
  final int remainingSeconds;
  final int totalPhaseSeconds;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int completedFocusSessions;
  final int cycleIndex;

  const FocusSessionState({
    required this.phase,
    required this.isRunning,
    required this.remainingSeconds,
    required this.totalPhaseSeconds,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.completedFocusSessions,
    required this.cycleIndex,
  });

  double get progress =>
      totalPhaseSeconds == 0 ? 0 : 1 - (remainingSeconds / totalPhaseSeconds);

  FocusSessionState copyWith({
    FocusPhase? phase,
    bool? isRunning,
    int? remainingSeconds,
    int? totalPhaseSeconds,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? completedFocusSessions,
    int? cycleIndex,
  }) {
    return FocusSessionState(
      phase: phase ?? this.phase,
      isRunning: isRunning ?? this.isRunning,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalPhaseSeconds: totalPhaseSeconds ?? this.totalPhaseSeconds,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      completedFocusSessions: completedFocusSessions ?? this.completedFocusSessions,
      cycleIndex: cycleIndex ?? this.cycleIndex,
    );
  }
}

class FocusSessionNotifier extends Notifier<FocusSessionState> {
  Timer? _ticker;

  @override
  FocusSessionState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const FocusSessionState(
      phase: FocusPhase.focus,
      isRunning: false,
      remainingSeconds: 25 * 60,
      totalPhaseSeconds: 25 * 60,
      focusMinutes: 25,
      shortBreakMinutes: 5,
      longBreakMinutes: 15,
      completedFocusSessions: 0,
      cycleIndex: 0,
    );
  }

  void toggleRun() {
    if (state.isRunning) {
      _ticker?.cancel();
      state = state.copyWith(isRunning: false);
      return;
    }

    _ticker?.cancel();
    state = state.copyWith(isRunning: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _advancePhase();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void resetCurrentPhase() {
    _ticker?.cancel();
    state = state.copyWith(
      isRunning: false,
      remainingSeconds: state.totalPhaseSeconds,
    );
  }

  void skipPhase() {
    _advancePhase(autoStart: false);
  }

  void updateDurations({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) {
    final nextFocus = focusMinutes ?? state.focusMinutes;
    final nextShort = shortBreakMinutes ?? state.shortBreakMinutes;
    final nextLong = longBreakMinutes ?? state.longBreakMinutes;

    state = state.copyWith(
      focusMinutes: nextFocus,
      shortBreakMinutes: nextShort,
      longBreakMinutes: nextLong,
    );

    if (!state.isRunning) {
      final seconds = _secondsForPhase(state.phase);
      state = state.copyWith(
        remainingSeconds: seconds,
        totalPhaseSeconds: seconds,
      );
    }
  }

  void _advancePhase({bool autoStart = true}) {
    final currentPhase = state.phase;
    FocusPhase nextPhase;
    var completedFocusSessions = state.completedFocusSessions;
    var cycleIndex = state.cycleIndex;

    if (currentPhase == FocusPhase.focus) {
      completedFocusSessions += 1;
      cycleIndex += 1;
      nextPhase = cycleIndex % 4 == 0 ? FocusPhase.longBreak : FocusPhase.shortBreak;
    } else {
      nextPhase = FocusPhase.focus;
    }

    final seconds = _secondsForPhase(nextPhase);
    state = state.copyWith(
      phase: nextPhase,
      remainingSeconds: seconds,
      totalPhaseSeconds: seconds,
      completedFocusSessions: completedFocusSessions,
      cycleIndex: cycleIndex,
      isRunning: autoStart,
    );

    _ticker?.cancel();
    if (autoStart) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.remainingSeconds <= 1) {
          _advancePhase();
        } else {
          state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        }
      });
    }
  }

  int _secondsForPhase(FocusPhase phase) {
    return switch (phase) {
      FocusPhase.focus => state.focusMinutes * 60,
      FocusPhase.shortBreak => state.shortBreakMinutes * 60,
      FocusPhase.longBreak => state.longBreakMinutes * 60,
    };
  }
}

final focusSessionProvider =
    NotifierProvider<FocusSessionNotifier, FocusSessionState>(
  FocusSessionNotifier.new,
);

final focusIntentProvider = StateProvider<String>((_) => '');
