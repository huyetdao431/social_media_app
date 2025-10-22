import 'package:flutter/material.dart';

class LoadingLine extends StatefulWidget {
  /// full width (default infinite)
  final double width;

  /// height of the bar
  final double height;

  /// bar corner radius
  final BorderRadius borderRadius;

  /// background color (white by default)
  final Color baseColor;

  /// highlight color (red)
  final Color bandColor;

  /// animation period
  final Duration period;

  /// proportion of width used as maximum band length (0..1)
  final double maxBandFraction;

  /// phase durations, sum must be 1.0
  final double growPhase; // fraction of total duration
  final double slidePhase;
  final double shrinkPhase;

  /// pause animation
  final bool paused;

  LoadingLine({
    super.key,
    this.width = double.infinity,
    this.height = 10.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.baseColor = Colors.white,
    this.bandColor = const Color(0xFFEF4444), // red-500
    this.period = const Duration(milliseconds: 1400),
    this.maxBandFraction = 0.35,
    this.growPhase = 0.2,
    this.slidePhase = 0.6,
    this.shrinkPhase = 0.2,
    this.paused = false,
  }) : assert(maxBandFraction > 0 && maxBandFraction <= 1.0),
       assert(growPhase > 0 && slidePhase >= 0 && shrinkPhase > 0),
       assert((growPhase + slidePhase + shrinkPhase - 1.0).abs() < 1e-6, 'growPhase + slidePhase + shrinkPhase must equal 1.0');

  @override
  State<LoadingLine> createState() => _LoadingLineState();
}

class _LoadingLineState extends State<LoadingLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.period);
    if (!widget.paused) _ctl.repeat();
  }

  @override
  void didUpdateWidget(covariant LoadingLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _ctl.duration = widget.period;
      _ctl
        ..reset()
        ..repeat();
    }
    if (oldWidget.paused != widget.paused) {
      if (widget.paused) {
        _ctl.stop();
      } else {
        if (!_ctl.isAnimating) _ctl.repeat();
      }
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, child) {
            return CustomPaint(
              painter: _BandPainter(
                progress: _ctl.value,
                baseColor: widget.baseColor,
                bandColor: widget.bandColor,
                maxBandFraction: widget.maxBandFraction,
                growPhase: widget.growPhase,
                slidePhase: widget.growPhase + widget.slidePhase, // cumulative
                // shrinkPhase not needed cumulative because end is 1.0
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

class _BandPainter extends CustomPainter {
  final double progress; // 0..1
  final Color baseColor;
  final Color bandColor;
  final double maxBandFraction;
  final double growPhase; // e.g. 0.2
  final double slidePhase; // cumulative e.g. 0.8 meaning growPhase..slidePhase is slide

  _BandPainter({
    required this.progress,
    required this.baseColor,
    required this.bandColor,
    required this.maxBandFraction,
    required this.growPhase,
    required this.slidePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // draw base
    final basePaint = Paint()..color = baseColor;
    canvas.drawRect(Offset.zero & size, basePaint);

    final w = size.width;
    if (w <= 0 || size.height <= 0) return;

    final maxLen = (maxBandFraction.clamp(0.0, 1.0)) * w;
    // Determine phase
    if (progress <= growPhase) {
      // Grow phase: left = 0; length grows 0 -> maxLen
      final localT = growPhase == 0 ? 1.0 : (progress / growPhase);
      final len = maxLen * localT;
      final left = 0.0;
      final right = left + len;
      _drawBand(canvas, size, left, right);
    } else if (progress <= slidePhase) {
      // Slide phase: band has fixed length = maxLen; move left from 0 -> (w - maxLen)
      final localT = (progress - growPhase) / (slidePhase - growPhase);
      final left = (w - maxLen) * localT;
      final right = left + maxLen;
      _drawBand(canvas, size, left, right);
    } else {
      // Shrink phase: right anchored at w; left moves from (w - maxLen) -> w  (band shortens)
      final localT = (progress - slidePhase) / (1.0 - slidePhase);
      final left = (w - maxLen) + maxLen * localT;
      final right = w;
      _drawBand(canvas, size, left, right);
    }
  }

  void _drawBand(Canvas canvas, Size size, double left, double right) {
    // clamp
    left = left.clamp(0.0, size.width);
    right = right.clamp(0.0, size.width);
    if (right <= left) return;

    // optional: draw a subtle horizontal gradient inside the band for nicer look
    final rect = Rect.fromLTWH(left, 0, right - left, size.height);
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [bandColor.withOpacity(0.95), bandColor.withOpacity(0.65), bandColor.withOpacity(0.95)],
      stops: const [0.15, 0.5, 0.85],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _BandPainter old) {
    return old.progress != progress || old.baseColor != baseColor || old.bandColor != bandColor || old.maxBandFraction != maxBandFraction;
  }
}
