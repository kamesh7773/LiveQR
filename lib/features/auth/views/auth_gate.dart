import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../home/views/home_screen.dart';
import '../view_models/auth_view_model.dart';
import 'login_screen.dart';

/// Root route: shows [HomeScreen] when signed in, otherwise [LoginScreen].
/// Swaps automatically on sign-in/sign-out, so no navigation is needed.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(authUserProvider)
        .when(
          data: (user) =>
              user == null ? const LoginScreen() : const HomeScreen(),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => const LoginScreen(),
        );
  }
}
