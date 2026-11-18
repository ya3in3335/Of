import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme/app_colors.dart';

/// True once the intro animation has played. The router keeps the splash
/// on screen until then (and, after that, while the session is restored).
class SplashGate extends Notifier<bool> {
  @override
  bool build() => false;

  void finish() => state = true;
}

final splashGateProvider = NotifierProvider<SplashGate, bool>(SplashGate.new);

/// Motion-graphics intro built from the OutiFor logo, split into four layers
/// (assets/brand/splash): hammer, motion lines, wordmark, subtitle.
///
/// Timeline (2.3 s, tap to skip):
///   0–22 %   hammer fades in and winds up (anticipation)
///   22–38 %  strike: hammer swings down; motion lines trail behind the head
///   38 %     impact: haptic tick, shockwave ring, sparks, small shake,
///            "OutiFor" bursts out of the impact point
///   38–56 %  hammer recoils and settles
///   55–78 %  subtitle wipes in from the left
///   78–95 %  light sweep across the wordmark
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  static const _layers = ['lines', 'hammer', 'wordmark', 'subtitle'];

  // Layer canvas is 1044 × 540 px; these points are in that space.
  static const _canvas = Size(1044, 540);
  static const _pivot = Offset(182, 302); // where the hand holds the handle
  static const _impact = Offset(528, 312); // hammer head meets the "i"

  static const _impactT = 0.38;

  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2300));
  bool _started = false;
  bool _hapticDone = false;
  bool _completed = false;

  static Alignment _align(Offset p) => Alignment(p.dx / _canvas.width * 2 - 1, p.dy / _canvas.height * 2 - 1);

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (!_hapticDone && _c.value >= _impactT) {
        _hapticDone = true;
        HapticFeedback.mediumImpact();
      }
    });
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _completed = true);
        ref.read(splashGateProvider.notifier).finish();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    for (final l in _layers) {
      precacheImage(AssetImage('assets/brand/splash/$l.png'), context);
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1; // reduced motion: show the finished logo
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(splashGateProvider.notifier).finish());
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // ---- easing helpers ------------------------------------------------------

  double _seg(double t, double a, double b, [Curve curve = Curves.linear]) =>
      curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  double _hammerAngle(double t) {
    if (t < 0.22) return _lerp(-0.35, -0.95, _seg(t, 0, 0.22, Curves.easeOutBack));
    if (t < _impactT) return _lerp(-0.95, 0, _seg(t, 0.22, _impactT, Curves.easeInQuart));
    final p = _seg(t, _impactT, 0.56);
    return -0.11 * math.sin(p * math.pi) * (1 - p * 0.4);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width * 0.8, 380.0);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_c.isAnimating) _c.value = 1;
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: width,
                child: AspectRatio(
                  aspectRatio: _canvas.width / _canvas.height,
                  child: AnimatedBuilder(animation: _c, builder: (context, _) => _logo(_c.value, width)),
                ),
              ),
              const SizedBox(height: 40),
              // Only if restoring the session takes longer than the intro.
              AnimatedOpacity(
                opacity: _completed ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.navy),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.splashLoading,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _layer(String name) => Image.asset(
    'assets/brand/splash/$name.png',
    fit: BoxFit.fill,
    filterQuality: FilterQuality.medium,
    gaplessPlayback: true,
  );

  Widget _logo(double t, double width) {
    final px = width / _canvas.width; // canvas px -> logical px

    // Impact shake: short damped horizontal oscillation.
    final shakeP = _seg(t, _impactT, 0.50);
    final shake = shakeP > 0 && shakeP < 1 ? math.sin(shakeP * math.pi * 6) * 7 * px * 2 * (1 - shakeP) : 0.0;

    // Hammer
    final hammer = Opacity(
      opacity: _seg(t, 0, 0.10),
      child: Transform.rotate(angle: _hammerAngle(t), alignment: _align(_pivot), child: _layer('hammer')),
    );

    // Motion lines streak in along their own direction during the strike.
    final lp = _seg(t, _impactT - 0.03, 0.50, Curves.easeOutCubic);
    final lines = Opacity(
      opacity: lp,
      child: Transform.translate(offset: Offset(30 * px * (1 - lp), 46 * px * (1 - lp)), child: _layer('lines')),
    );

    // Wordmark bursts out of the impact point, then a light sweep crosses it.
    final wp = _seg(t, _impactT, 0.60, Curves.easeOutBack);
    Widget wordmark = Opacity(
      opacity: _seg(t, _impactT, _impactT + 0.06),
      child: Transform.scale(scale: _lerp(0.45, 1, wp), alignment: _align(_impact), child: _layer('wordmark')),
    );
    final sp = _seg(t, 0.78, 0.95, Curves.easeInOut);
    if (sp > 0 && sp < 1) {
      final c = -0.3 + sp * 1.6;
      wordmark = ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0x00FFFFFF), Color(0x8CFFFFFF), Color(0x00FFFFFF)],
          stops: [(c - 0.12).clamp(0.0, 1.0), c.clamp(0.0, 1.0), (c + 0.12).clamp(0.0, 1.0)],
        ).createShader(rect),
        child: wordmark,
      );
    }

    // Subtitle wipes in left to right (the logo is always Latin, LTR).
    final up = _seg(t, 0.55, 0.78, Curves.easeOutCubic);
    final subtitle = Transform.translate(
      offset: Offset(0, 14 * px * (1 - up)),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => LinearGradient(
          colors: const [Colors.white, Color(0x00FFFFFF)],
          stops: [up, (up + 0.08).clamp(0.0, 1.0)],
        ).createShader(rect),
        child: _layer('subtitle'),
      ),
    );

    return Transform.translate(
      offset: Offset(shake, 0),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ImpactPainter(
                progress: _seg(t, _impactT, 0.66),
                center: Offset(_impact.dx * px, _impact.dy * px),
                scale: px,
              ),
            ),
          ),
          wordmark,
          subtitle,
          lines,
          hammer,
        ],
      ),
    );
  }
}

/// Shockwave ring and sparks at the moment of impact.
class _ImpactPainter extends CustomPainter {
  _ImpactPainter({required this.progress, required this.center, required this.scale});
  final double progress;
  final Offset center;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final e = Curves.easeOutCubic.transform(progress);
    final fade = 1 - progress;

    // Two concentric rings: brand red, then navy, slightly delayed.
    for (final (delay, color) in [(0.0, AppColors.brandRed), (0.12, AppColors.navy)]) {
      final q = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (q <= 0) continue;
      final r = Curves.easeOutCubic.transform(q) * 260 * scale;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (10 * (1 - q) + 1) * scale
          ..color = color.withValues(alpha: 0.55 * (1 - q)),
      );
    }

    // Sparks flying out (upper half: the hammer hits from above).
    final spark = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7 * scale * fade + 1;
    const angles = [-2.6, -2.15, -1.75, -1.4, -1.0, -0.55, -0.15];
    for (var i = 0; i < angles.length; i++) {
      final a = angles[i];
      final dir = Offset(math.cos(a), math.sin(a));
      final start = center + dir * (40 + 120 * e) * scale;
      final end = center + dir * (70 + 190 * e) * scale;
      spark.color = (i.isEven ? AppColors.brandRed : AppColors.cyan).withValues(alpha: fade);
      canvas.drawLine(start, end, spark);
    }
  }

  @override
  bool shouldRepaint(_ImpactPainter old) => old.progress != progress;
}
