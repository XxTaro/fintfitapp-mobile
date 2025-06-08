import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:fin_fit_app_mobile/ui/initial_page.dart';
import 'package:fin_fit_app_mobile/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading) {
      return loading();
    } else if (auth.currentUser == null) {
      return const LoginPage(key: ValueKey('statefulLoginPage'),);
    }

    return const InitialPage(title: "FinFitApp",);
  }

  Widget loading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(key: const ValueKey("authLoadingProgressIndicator"),),
      ),
    );
  }
}