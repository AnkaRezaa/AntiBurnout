import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/preferences_page.dart';
import '../../features/profile/presentation/pages/help_page.dart';
import '../../features/profile/presentation/pages/about_page.dart';
import '../../features/profile/presentation/pages/personalization_page.dart';
import '../../features/recommendations/presentation/pages/recommendation_page.dart';
import '../../features/results/presentation/pages/result_page.dart';
import '../../features/survey/presentation/pages/survey_intro_page.dart';
import '../../features/survey/presentation/pages/survey_question_page.dart';
import '../navigation/main_shell.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (previous, next) => refresh.value++);

  final router = GoRouter(
    initialLocation: RoutePaths.welcome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute =
          location == RoutePaths.welcome ||
          location == RoutePaths.login ||
          location == RoutePaths.register ||
          location == RoutePaths.forgotPassword;

      if (auth.status == AuthStatus.unknown) return null;
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => DashboardPage(
                  onStartSurvey: () => context.push(RoutePaths.dashboardSurvey),
                  onViewHistory: () =>
                      StatefulNavigationShell.of(context).goBranch(2),
                  onProfileTap: () =>
                      StatefulNavigationShell.of(context).goBranch(3),
                ),
                routes: [
                  GoRoute(
                    path: 'survey',
                    builder: (context, state) => SurveyIntroPage(
                      onStartSurvey: () => context.push(
                        RoutePaths.questionsFor(SurveyOrigin.dashboard),
                      ),
                      onLater: () => context.pop(),
                    ),
                    routes: [_questionsRoute(SurveyOrigin.dashboard)],
                  ),
                  _resultRoute(),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.survey,
                builder: (context, state) => SurveyIntroPage(
                  onStartSurvey: () => context.push(
                    RoutePaths.questionsFor(SurveyOrigin.surveyTab),
                  ),
                  onLater: () =>
                      StatefulNavigationShell.of(context).goBranch(0),
                ),
                routes: [
                  _questionsRoute(SurveyOrigin.surveyTab),
                  _resultRoute(),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.history,
                builder: (context, state) => HistoryPage(
                  onBack: () => StatefulNavigationShell.of(context).goBranch(0),
                  onViewDetail: (item) =>
                      context.push(RoutePaths.resultFor(item.id)),
                ),
                routes: [_resultRoute()],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => ProfilePage(
                  onEditProfile: () => context.push(RoutePaths.editProfile),
                  onPreferences: () => context.push(RoutePaths.preferences),
                  onHelp: () => context.push(RoutePaths.help),
                  onAbout: () => context.push(RoutePaths.about),
                  onPersonalization: () =>
                      context.push(RoutePaths.personalization),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => Consumer(
                      builder: (context, ref, child) => EditProfilePage(
                        key: ValueKey(
                          ref.watch(
                            authControllerProvider.select(
                              (auth) => auth.user?.id,
                            ),
                          ),
                        ),
                        onBack: () => context.pop(),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'preferences',
                    builder: (context, state) =>
                        PreferencesPage(onBack: () => context.pop()),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) =>
                        HelpPage(onBack: () => context.pop()),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) =>
                        AboutPage(onBack: () => context.pop()),
                  ),
                  GoRoute(
                    path: 'personalization',
                    builder: (context, state) =>
                        PersonalizationPage(onBack: () => context.pop()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

GoRoute _questionsRoute(SurveyOrigin origin) => GoRoute(
  path: 'questions',
  builder: (context, state) => SurveyQuestionPage(
    sessionKey: origin.name,
    onBack: () => context.pop(),
    onSubmitted: (assessment) {
      // Replace the completed form and entry pages with the correct branch
      // root + result. UI and Android back then share the same stack.
      context.go(RoutePaths.submittedResultFor(origin, assessment.id));
    },
  ),
);

GoRoute _resultRoute() => GoRoute(
  path: 'result/:assessmentId',
  builder: (context, state) => ResultPage(
    assessmentId: state.pathParameters['assessmentId']!,
    onBack: () => context.pop(),
    onRecommendationTap: () =>
        context.push('${state.uri.path}/recommendations'),
  ),
  routes: [
    GoRoute(
      path: 'recommendations',
      builder: (context, state) => RecommendationPage(
        assessmentId: state.pathParameters['assessmentId']!,
        onBack: () => context.pop(),
      ),
    ),
  ],
);
