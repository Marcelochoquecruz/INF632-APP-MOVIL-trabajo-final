import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/admin/admin_panel.dart';
import '../screens/doctor/doctor_dashboard.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String welcome = '/welcome';
  static const String adminPanel = '/admin-panel';
  static const String doctorDashboard = '/doctor-dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (_) => const HomeScreen(),
      login: (_) => const LoginScreen(),
      welcome: (_) => const WelcomeScreen(),
      adminPanel: (_) => const AdminPanel(),
      doctorDashboard: (_) => const DoctorDashboard(),
    };
  }
}
