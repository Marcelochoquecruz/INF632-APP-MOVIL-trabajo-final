import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool useGradient;

  const GradientBackground({
    Key? key,
    required this.child,
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPurple,
        gradient: useGradient
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 1.0],
                colors: [
                  AppColors.primaryPurple.withOpacity(0.5),
                  AppColors.backgroundPurple,
                  AppColors.backgroundPurple,
                ],
              )
            : null,
      ),
      child: child,
    );
  }
}
