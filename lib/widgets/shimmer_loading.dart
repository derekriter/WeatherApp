import 'package:flutter/material.dart';

//Based on https://docs.flutter.dev/cookbook/effects/shimmer-loading

class ShimmerRoot extends StatefulWidget {
  const ShimmerRoot({
    super.key,
    this.child,
    required this.background,
    required this.glint,
  });

  final Color background, glint;
  final Widget? child;

  static ShimmerRootState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerRootState>();
  }

  @override
  State<ShimmerRoot> createState() => ShimmerRootState();
}

class ShimmerRootState extends State<ShimmerRoot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }

  Gradient get gradient => LinearGradient(
    colors: [widget.background, widget.glint, widget.background],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1, -0.3),
    end: Alignment(1, 0.3),
    transform: _SlidingGradientTransform(slidePercent: _controller.value),
  );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerUpdate => _controller;
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({required this.child, super.key});

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _updates;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_updates != null) {
      _updates!.removeListener(_onUpdate);
    }
    _updates = ShimmerRoot.of(context)?.shimmerUpdate;
    if (_updates != null) {
      _updates!.addListener(_onUpdate);
    }
  }

  void _onUpdate() {
    setState(() {}); //force the widget to re-render
  }

  @override
  Widget build(BuildContext context) {
    final root = ShimmerRoot.of(context)!;
    if (!root.isSized) {
      return const SizedBox();
    }
    final rootSize = root.size;
    final rootGradient = root.gradient;
    final offsetFromRoot = root.getDescendantOffset(
      descendant: context.findRenderObject() as RenderBox,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return rootGradient.createShader(
          Rect.fromLTWH(
            -offsetFromRoot.dx,
            -offsetFromRoot.dy,
            rootSize.width,
            rootSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
