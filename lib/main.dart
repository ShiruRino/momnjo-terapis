import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/shell/main_navigation_shell.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await AppState.instance.restoreSession();
  runApp(const MomnjoTherapistApp());
}

class MomnjoTherapistApp extends StatelessWidget {
  const MomnjoTherapistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Momnjo Terapis',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: AppState.instance.isLoggedIn
              ? const MainNavigationShell()
              : const LoginScreen(),
        );
      },
    );
  }
}
