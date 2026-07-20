import 'package:flutter/material.dart';

import 'design_gallery_screen.dart';
import 'forgot_password_screen.dart';
import 'furniture_library_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'models/room_designer_args.dart';
import 'room_designer_screen.dart';
import 'screens/ai_image_generator.dart';
import 'screens/template_room_setup_screen.dart';
import 'settings_screen.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';
import 'src/features/auth/auth_gate_screen.dart';
import 'src/features/dashboard/app_dashboard_screen.dart';
import 'src/features/design/two_step_design_args.dart';
import 'src/features/design/two_step_design_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String authGate = '/auth-gate';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String settingsRoute = '/settings';
  static const String gallery = '/gallery';
  static const String roomDesigner = '/room-designer';
  static const String templateRoomSetup = '/template-room-setup';
  static const String furnitureLibrary = '/furniture-library';
  static const String aiBlueprint = '/ai-blueprint';
  static const String aiImage = '/ai-image';
  static const String createDesign = '/create-design';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(
          builder: (_) => const AuthGateScreen(),
          settings: settings,
        );
      case splash:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
          settings: settings,
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const AppDashboardScreen(),
          settings: settings,
        );
      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(),
          settings: settings,
        );
      case gallery:
        return MaterialPageRoute(
          builder: (_) => DesignGalleryScreen(),
          settings: settings,
        );
      case roomDesigner:
        final roomArgs = settings.arguments is RoomDesignerArgs
            ? settings.arguments as RoomDesignerArgs
            : null;
        return MaterialPageRoute(
          builder: (_) => RoomDesignerScreen(args: roomArgs),
          settings: settings,
        );
      case templateRoomSetup:
        final setupArgs = settings.arguments;
        if (setupArgs is! TemplateSetupArgs) {
          return MaterialPageRoute(
            builder: (_) =>
                Scaffold(body: Center(child: Text('Missing template setup'))),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => TemplateRoomSetupScreen(args: setupArgs),
          settings: settings,
        );
      case furnitureLibrary:
        return MaterialPageRoute(
          builder: (_) => FurnitureLibraryScreen(),
          settings: settings,
        );
      case aiBlueprint:
        return MaterialPageRoute(
          // Keep old route for backward compatibility, but use single AI screen.
          builder: (_) => const AIImageGenerator(),
          settings: settings,
        );
      case aiImage:
        return MaterialPageRoute(
          builder: (_) => const AIImageGenerator(),
          settings: settings,
        );
      case createDesign:
        final args = settings.arguments is TwoStepDesignArgs
            ? settings.arguments as TwoStepDesignArgs
            : const TwoStepDesignArgs(initialType: 'interior');
        return MaterialPageRoute(
          builder: (_) => TwoStepDesignScreen(
            initialType: args.initialType,
            initialStyle: args.initialStyle,
            initialColor: args.initialColor,
            initialPrompt: args.initialPrompt,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
