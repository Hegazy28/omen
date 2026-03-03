// lib/features/matches/widgets/live_indicator.dart
//
// Animated pulsing red dot with "LIVE" label.

import 'package:flutter/material.dart';
import 'matches_theme.dart';

class LiveIndicator extends StatefulWidget {
  final int? minute;
  const LiveIndicator({super.key, this.minute});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MatchColors.live.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: MatchColors.live.withOpacity(0.30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MatchColors.live,
                boxShadow: [
                  BoxShadow(
                    color: MatchColors.live.withOpacity(0.3 + 0.4 * _pulse.value),
                    blurRadius: 4 + 4 * _pulse.value,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.minute != null ? "${widget.minute}'" : 'LIVE',
            style: MatchTextStyles.mono(9, color: MatchColors.live),
          ),
        ],
      ),
    );
  }
}
