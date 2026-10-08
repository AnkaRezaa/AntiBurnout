import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/recommendations/presentation/pages/recommendation_page.dart';
import '../../features/results/presentation/pages/result_page.dart';
import '../navigation/main_shell.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen(
    authControllerProvider,
    (previous, next) => refresh.value++,
  );

  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutePaths.welcome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      final isAuthRoute = location == RoutePaths.welcome ||
          location == RoutePaths.login ||
          location == RoutePaths.register ||
          location == RoutePaths.forgotPassword;

      if (auth.status == AuthStatus.unknown) {
        return null;
      }

      if (auth.status == AuthStatus.authenticated && isAuthRoute) {
        return RoutePaths.home;
      }

      if (auth.status == AuthStatus.unauthenticated && !isAuthRoute) {
        return RoutePaths.welcome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: RoutePaths.result,
        builder: (context, state) => const ResultPage(),
      ),
      GoRoute(
        path: RoutePaths.recommendation,
        builder: (context, state) => const RecommendationPage(),
      ),
    ],
  );
});