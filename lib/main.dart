import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/app_shell.dart';
import 'screens/login_page_screen.dart';

void main() {
  runApp(const SafescapeApp());
}

class SafescapeApp extends StatelessWidget {
  const SafescapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Safescape",
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLoggedIn = false;

  void loginSuccess() {
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return const AppShell();
    } else {
      return LoginPage(onLoginSuccess: loginSuccess);
    }
  }
}