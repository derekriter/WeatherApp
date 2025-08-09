import 'package:flutter/material.dart';
import 'package:weather_app/widgets/shimmer_loading.dart';

class LoadingBox extends StatelessWidget {
  const LoadingBox({super.key, required this.width, required this.height});

  final double width, height;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
