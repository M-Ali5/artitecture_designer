import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../login_screen.dart';
import 'auth_controller.dart';
import '../dashboard/app_dashboard_screen.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.isLoggedIn) {
      return const AppDashboardScreen();
    }
    return const LoginScreen();
  }
}
