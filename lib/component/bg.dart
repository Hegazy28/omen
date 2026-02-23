import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  USAGE:
//  WinterBackground(child: YourTaskScreenWidget())
// ─────────────────────────────────────────────

class WinterBackground extends StatefulWidget {
  final Widget? child;
  const WinterBackground({super.key, this.child});

  @override
  State<WinterBackground> createState() => _WinterBackgroundState();
}

class _WinterBackgroundState extends State<WinterBackground>
    with TickerProviderStateMixin {
  late AnimationController _snowController;
  late AnimationController _auroraController;
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late AnimationController _waveController;
  late AnimationController _sparkleController;
  late AnimationController _fogController;

  final List<SnowParticle> _flakes = [];
  final List<IceCrystal> _crystals = [];
  final List<FogLayer> _fogLayers = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )
      ..addListener(() => setState(() => _tickSnow()))
      ..repeat();

    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 100; i++) {
      final tier = i % 3;
      _flakes.add(SnowParticle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        radius: tier == 0
            ? _rng.nextDouble() * 1.5 + 0.8
            : tier == 1
                ? _rng.nextDouble() * 2.0 + 1.5
                : _rng.nextDouble() * 2.5 + 2.5,
        speed: tier == 0
            ? _rng.nextDouble() * 0.006 + 0.002
            : tier == 1
                ? _rng.nextDouble() * 0.010 + 0.004
                : _rng.nextDouble() * 0.014 + 0.006,
        drift: _rng.nextDouble() * 0.004 - 0.002,
        opacity: tier == 0
            ? _rng.nextDouble() * 0.3 + 0.15
            : tier == 1
                ? _rng.nextDouble() * 0.4 + 0.35
                : _rng.nextDouble() * 0.35 + 0.55,
        phase: _rng.nextDouble() * 2 * pi,
        blur: tier == 0
            ? 0.8
            : tier == 1
                ? 1.2
                : 0.4,
      ));
    }

    for (int i = 0; i < 28; i++) {
      _crystals.add(IceCrystal(
        x: _rng.nextDouble(),
        y: _rng.nextDouble() * 0.85,
        size: _rng.nextDouble() * 4 + 2,
        phase: _rng.nextDouble() * 2 * pi,
        speed: _rng.nextDouble() * 0.6 + 0.4,
      ));
    }

    for (int i = 0; i < 3; i++) {
      _fogLayers.add(FogLayer(
        yFrac: 0.60 + i * 0.13,
        speed: 0.04 + i * 0.015,
        opacity: 0.04 + i * 0.02,
        phase: _rng.nextDouble() * 2 * pi,
      ));
    }
  }

  void _tickSnow() {
    for (final f in _flakes) {
      f.y += f.speed;
      f.x += f.drift + sin(_snowController.value * 2 * pi + f.phase) * 0.0015;
      if (f.y > 1.06) {
        f.y = -0.06;
        f.x = _rng.nextDouble();
      }
      if (f.x > 1.06) f.x = -0.06;
      if (f.x < -0.06) f.x = 1.06;
    }
  }

  @override
  void dispose() {
    _snowController.dispose();
    _auroraController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _waveController.dispose();
    _sparkleController.dispose();
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _auroraController,
        _orb1Controller,
        _orb2Controller,
        _orb3Controller,
        _waveController,
        _sparkleController,
        _fogController,
      ]),
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        return Stack(
          children: [
            _buildSky(),
            _buildAuroraBands(size),
            _buildStars(),
            _buildOrb(
              controller: _orb1Controller,
              color: const Color(0xFF1E90FF),
              startX: 0.15,
              startY: 0.22,
              endX: 0.25,
              endY: 0.30,
              radius: size.width * 0.38,
              opacity: 0.13,
            ),
            _buildOrb(
              controller: _orb2Controller,
              color: const Color(0xFF00BFFF),
              startX: 0.70,
              startY: 0.15,
              endX: 0.80,
              endY: 0.28,
              radius: size.width * 0.42,
              opacity: 0.10,
            ),
            _buildOrb(
              controller: _orb3Controller,
              color: const Color(0xFF87CEEB),
              startX: 0.45,
              startY: 0.50,
              endX: 0.55,
              endY: 0.60,
              radius: size.width * 0.30,
              opacity: 0.08,
            ),
            _buildFog(size),
            CustomPaint(
              painter: SnowPainter(flakes: _flakes),
              child: const SizedBox.expand(),
            ),
            CustomPaint(
              painter: SparklePainter(
                crystals: _crystals,
                time: _sparkleController.value,
              ),
              child: const SizedBox.expand(),
            ),
            _buildFrostWave(size),
            _buildVignette(),
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }

  Widget _buildSky() {
    final t = _auroraController.value;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF010916), const Color(0xFF020D1F), t)!,
            Color.lerp(const Color(0xFF041228), const Color(0xFF071A38), t)!,
            Color.lerp(const Color(0xFF0A2248), const Color(0xFF102C5A), t)!,
            Color.lerp(const Color(0xFF143570), const Color(0xFF1A4080), t)!,
          ],
          stops: const [0.0, 0.3, 0.65, 1.0],
        ),
      ),
    );
  }

  Widget _buildAuroraBands(Size size) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: size.height * 0.55,
      child: CustomPaint(
        painter: AuroraPainter(t: _auroraController.value),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildStars() {
    return CustomPaint(
      painter: StarPainter(seed: 99, twinkle: _sparkleController.value),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildOrb({
    required AnimationController controller,
    required Color color,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required double radius,
    required double opacity,
  }) {
    final t = controller.value;
    final cx = startX + (endX - startX) * t;
    final cy = startY + (endY - startY) * t;
    return Positioned.fill(
      child: CustomPaint(
        painter: OrbPainter(
            cx: cx, cy: cy, radius: radius, color: color, opacity: opacity),
      ),
    );
  }

  Widget _buildFog(Size size) {
    return Positioned.fill(
      child: CustomPaint(
        painter: FogPainter(layers: _fogLayers, progress: _fogController.value),
      ),
    );
  }

  Widget _buildFrostWave(Size size) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: size.height * 0.22,
      child: CustomPaint(
        painter: FrostWavePainter(
          progress: _waveController.value,
          shimmer: _sparkleController.value,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildVignette() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              Colors.transparent,
              const Color(0xFF010916).withOpacity(0.25),
              const Color(0xFF010916).withOpacity(0.55),
            ],
            stops: const [0.55, 0.82, 1.0],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────────────────

class SnowParticle {
  double x, y, radius, speed, drift, opacity, phase, blur;
  SnowParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.phase,
    required this.blur,
  });
}

class IceCrystal {
  final double x, y, size, phase, speed;
  const IceCrystal({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.speed,
  });
}

class FogLayer {
  final double yFrac, speed, opacity, phase;
  const FogLayer({
    required this.yFrac,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

// ─────────────────────────────────────────────────────────
//  PAINTERS
// ─────────────────────────────────────────────────────────

class AuroraPainter extends CustomPainter {
  final double t;
  AuroraPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBand(canvas, size,
        yBase: size.height * (0.18 + sin(t * pi) * 0.05),
        amplitude: size.height * 0.10,
        waveOffset: t * 2 * pi,
        color: const Color(0xFF00BFFF),
        opacity: 0.07 + t * 0.05,
        bandWidth: size.height * 0.22);
    _drawBand(canvas, size,
        yBase: size.height * (0.28 + cos(t * pi * 0.7) * 0.04),
        amplitude: size.height * 0.07,
        waveOffset: t * 2 * pi + 1.2,
        color: const Color(0xFF4169E1),
        opacity: 0.06 + t * 0.04,
        bandWidth: size.height * 0.18);
    _drawBand(canvas, size,
        yBase: size.height * (0.12 + sin(t * pi * 1.3 + 0.5) * 0.04),
        amplitude: size.height * 0.06,
        waveOffset: t * 2 * pi + 2.4,
        color: const Color(0xFFADD8E6),
        opacity: 0.04 + t * 0.03,
        bandWidth: size.height * 0.10);
  }

  void _drawBand(
    Canvas canvas,
    Size size, {
    required double yBase,
    required double amplitude,
    required double waveOffset,
    required Color color,
    required double opacity,
    required double bandWidth,
  }) {
    const steps = 80;
    final topPts = <Offset>[];
    final botPts = <Offset>[];
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = yBase + sin(i / steps * 2 * pi + waveOffset) * amplitude;
      topPts.add(Offset(x, y - bandWidth));
      botPts.add(Offset(x, y));
    }
    final path = Path()..moveTo(topPts.first.dx, topPts.first.dy);
    for (final p in topPts) path.lineTo(p.dx, p.dy);
    for (final p in botPts.reversed) path.lineTo(p.dx, p.dy);
    path.close();

    canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
  }

  @override
  bool shouldRepaint(AuroraPainter old) => old.t != t;
}

class StarPainter extends CustomPainter {
  final int seed;
  final double twinkle;
  StarPainter({required this.seed, required this.twinkle});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.60;
      final r = rng.nextDouble() * 1.3 + 0.3;
      final phase = rng.nextDouble() * 2 * pi;
      final op = (0.3 + sin(twinkle * pi + phase) * 0.3).clamp(0.05, 0.85);
      canvas.drawCircle(
          Offset(x, y),
          r,
          Paint()
            ..color = Colors.white.withOpacity(op)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.6));
    }
  }

  @override
  bool shouldRepaint(StarPainter old) => old.twinkle != twinkle;
}

class OrbPainter extends CustomPainter {
  final double cx, cy, radius, opacity;
  final Color color;
  OrbPainter(
      {required this.cx,
      required this.cy,
      required this.radius,
      required this.color,
      required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(cx * size.width, cy * size.height);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.4),
              Colors.transparent
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.35));
  }

  @override
  bool shouldRepaint(OrbPainter old) => old.cx != cx || old.cy != cy;
}

class SnowPainter extends CustomPainter {
  final List<SnowParticle> flakes;
  SnowPainter({required this.flakes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in flakes) {
      canvas.drawCircle(
          Offset(f.x * size.width, f.y * size.height),
          f.radius,
          Paint()
            ..color = Colors.white.withOpacity(f.opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, f.blur));
    }
  }

  @override
  bool shouldRepaint(SnowPainter old) => true;
}

class SparklePainter extends CustomPainter {
  final List<IceCrystal> crystals;
  final double time;
  SparklePainter({required this.crystals, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in crystals) {
      final opacity = ((sin(time * pi * c.speed + c.phase) * 0.5 + 0.5) * 0.55)
          .clamp(0.0, 1.0);
      if (opacity < 0.04) continue;
      final cx = c.x * size.width;
      final cy = c.y * size.height;
      final paint = Paint()
        ..color = const Color(0xFFB8E8FF).withOpacity(opacity)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int arm = 0; arm < 6; arm++) {
        final angle = arm * pi / 3;
        canvas.drawLine(Offset(cx, cy),
            Offset(cx + cos(angle) * c.size, cy + sin(angle) * c.size), paint);
        final midX = cx + cos(angle) * c.size * 0.55;
        final midY = cy + sin(angle) * c.size * 0.55;
        final perp = angle + pi / 2;
        final cl = c.size * 0.28;
        canvas.drawLine(Offset(midX - cos(perp) * cl, midY - sin(perp) * cl),
            Offset(midX + cos(perp) * cl, midY + sin(perp) * cl), paint);
      }
      canvas.drawCircle(Offset(cx, cy), 1.2,
          Paint()..color = const Color(0xFFE8F8FF).withOpacity(opacity * 0.8));
    }
  }

  @override
  bool shouldRepaint(SparklePainter old) => old.time != time;
}

class FogPainter extends CustomPainter {
  final List<FogLayer> layers;
  final double progress;
  FogPainter({required this.layers, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      final offset = (progress * layer.speed + layer.phase / (2 * pi)) % 1.0;
      final y = layer.yFrac * size.height;
      const steps = 60;
      final path = Path()..moveTo(0, size.height);
      for (int i = 0; i <= steps * 2; i++) {
        final xFrac = i / (steps * 2);
        final x = xFrac * size.width * 2 - size.width * offset;
        final dy = sin(xFrac * 2 * pi * 2 + layer.phase) * 16;
        if (i == 0)
          path.moveTo(x, y + dy);
        else
          path.lineTo(x, y + dy);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF5BA8D4).withOpacity(layer.opacity),
                const Color(0xFF4090C0).withOpacity(layer.opacity * 0.3),
                Colors.transparent,
              ],
            ).createShader(Rect.fromLTWH(0, y - 40, size.width, 100))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    }
  }

  @override
  bool shouldRepaint(FogPainter old) => old.progress != progress;
}

class FrostWavePainter extends CustomPainter {
  final double progress;
  final double shimmer;
  FrostWavePainter({required this.progress, required this.shimmer});

  @override
  void paint(Canvas canvas, Size size) {
    const steps = 100;

    // Main frost surface
    final path1 = Path();
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = size.height * 0.30 +
          sin(i / steps * 2 * pi + progress * 2 * pi) * 12 +
          sin(i / steps * 3 * pi + progress * pi * 1.3) * 6;
      if (i == 0)
        path1.moveTo(x, y);
      else
        path1.lineTo(x, y);
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(
        path1,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(const Color(0xFF1A6FA8), const Color(0xFF2589C8),
                      shimmer)!
                  .withOpacity(0.55),
              const Color(0xFF0D2B5E).withOpacity(0.85),
              const Color(0xFF061228),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Shimmer highlight layer
    final path2 = Path();
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = size.height * 0.28 +
          sin(i / steps * 2 * pi + progress * 2 * pi + 0.8) * 9 +
          cos(i / steps * 4 * pi + progress * pi * 1.7) * 4;
      if (i == 0)
        path2.moveTo(x, y);
      else
        path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height * 0.45);
    path2.lineTo(0, size.height * 0.45);
    path2.close();
    canvas.drawPath(
        path2,
        Paint()
          ..color = Color.lerp(
                  const Color(0xFF5BB8E8), const Color(0xFF8DD6F5), shimmer)!
              .withOpacity(0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Ice edge highlight line
    final edgePath = Path();
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = size.height * 0.30 +
          sin(i / steps * 2 * pi + progress * 2 * pi) * 12 +
          sin(i / steps * 3 * pi + progress * pi * 1.3) * 6;
      if (i == 0)
        edgePath.moveTo(x, y);
      else
        edgePath.lineTo(x, y);
    }
    canvas.drawPath(
        edgePath,
        Paint()
          ..color = Colors.white.withOpacity(0.10 + shimmer * 0.12)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
  }

  @override
  bool shouldRepaint(FrostWavePainter old) =>
      old.progress != progress || old.shimmer != shimmer;
}
