import 'package:flutter/material.dart';
import '../../widgets/admin_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/gradient_background.dart';
import '../../utils/app_colors.dart';

class AdminBaseScreen extends StatefulWidget {
  final Widget child;
  final String title;
  final int currentIndex;

  const AdminBaseScreen({
    Key? key,
    required this.child,
    required this.title,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<AdminBaseScreen> createState() => _AdminBaseScreenState();
}

class _AdminBaseScreenState extends State<AdminBaseScreen> {
  void _onNavBarTap(int index) {
    switch (index) {
      case 0:
        if (widget.currentIndex != 0) {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        }
        break;
      case 1:
        if (widget.currentIndex != 1) {
          Navigator.pushReplacementNamed(context, '/admin/users');
        }
        break;
      case 2:
        if (widget.currentIndex != 2) {
          Navigator.pushReplacementNamed(context, '/admin/doctors');
        }
        break;
      case 3:
        if (widget.currentIndex != 3) {
          Navigator.pushReplacementNamed(context, '/admin/settings');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPurple,
      appBar: CustomAppBar(
        title: widget.title,
        showBackButton: false,
      ),
      body: GradientBackground(
        child: widget.child,
      ),
      bottomNavigationBar: AdminNavBar(
        currentIndex: widget.currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
