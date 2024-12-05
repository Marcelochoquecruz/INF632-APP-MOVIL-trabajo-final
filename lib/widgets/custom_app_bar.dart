import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A00E0), // Morado fuerte
            Color(0xFF8E2DE2), // Morado suave
            Color(0xFF00C9FF), // Azul claro
          ],
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions ?? [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
