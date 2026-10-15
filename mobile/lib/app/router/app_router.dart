import 'package:flutter/widgets.dart';
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
  final surveyNavigatorKey = GlobalKey<NavigatorState>();
  // An unfinished flow keeps its entry origin, even while only its intro is open.
  var surveyHasEntry = false;
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
        return auth.justRegistered
            ? RoutePaths.registrationPersonalization
            : RoutePaths.home;
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
        builder: (context, state, shell) => MainShell(
          navigationShell: shell,
          onBranchSelected: (index) {
            if (index == 1) surveyHasEntry = true;
          },
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => DashboardPage(
                  onStartSurvey: () {
                    final surveyNavigator = surveyNavigatorKey.currentState;
                    if (surveyNavigator != null &&
                        (surveyHasEntry || surveyNavigator.canPop())) {
                      StatefulNavigationShell.of(context).goBranch(1);
                    } else {
                      surveyHasEntry = true;
                      context.go(RoutePaths.dashboardSurvey);
                    }
                  },
                  onViewHistory: () =>
                      StatefulNavigationShell.of(context).goBranch(2),
                  onViewLatestAssessment: (id) =>
                      context.go(RoutePaths.resultFor(id)),
                  onProfileTap: () =>
                      StatefulNavigationShell.of(context).goBranch(3),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: surveyNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.survey,
                builder: (context, state) {
                  return SurveyIntroPage(
                    onStartSurvey: () {
                      surveyHasEntry = true;
                      context.push(
                        RoutePaths.questionsFor(_surveyOrigin(state)),
                      );
                    },
                    onLater: () =>
                        StatefulNavigationShell.of(context).goBranch(0),
                  );
                },
                routes: [
                  _questionsRoute(),
                  _resultRoute(
                    fromSurvey: true,
                    onSurveyFinished: () => surveyHasEntry = false,
                  ),
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
                    builder: (context, state) {
                      final fromRegistration =
                          state.uri.queryParameters['origin'] == 'registration';
                      return PersonalizationPage(
                        backTooltip: fromRegistration
                            ? 'Kembali ke beranda'
                            : 'Kembali ke profil',
                        onBack: () {
                          if (fromRegistration) {
                            ref
                                .read(authControllerProvider.notifier)
                                .finishRegistrationFlow();
                            _resetBranch(
                              context,
                              RoutePaths.profile,
                              returnHome: true,
                            );
                          } else {
                            context.pop();
                          }
                        },
                      );
                    },
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

SurveyOrigin _surveyOrigin(GoRouterState state) =>
    state.uri.queryParameters['origin'] == 'dashboard'
    ? SurveyOrigin.dashboard
    : SurveyOrigin.surveyTab;

GoRoute _questionsRoute() => GoRoute(
  path: 'questions',
  builder: (context, state) {
    final origin = _surveyOrigin(state);
    return SurveyQuestionPage(
      sessionKey: origin.name,
      onBack: () => context.pop(),
      onSubmitted: (assessment) {
        // Replace completed questions within the Survey branch so its cached
        // stack cannot restore a submitted form after switching tabs.
        context.go(RoutePaths.submittedResultFor(origin, assessment.id));
      },
    );
  },
);

void _resetBranch(
  BuildContext context,
  String branchRoot, {
  bool returnHome = false,
  VoidCallback? onReset,
}) {
  final router = GoRouter.of(context);
  router.go(branchRoot);
  // Let the shell cache the cleared branch stack before switching to Home.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (router.routeInformationProvider.value.uri == Uri.parse(branchRoot)) {
      onReset?.call();
      if (returnHome) router.go(RoutePaths.home);
    }
  });
}

GoRoute _resultRoute({
  bool fromSurvey = false,
  VoidCallback? onSurveyFinished,
}) => GoRoute(
  path: 'result/:assessmentId',
  builder: (context, state) {
    void onBack() {
      if (fromSurvey) {
        _resetBranch(
          context,
          RoutePaths.survey,
          returnHome: _surveyOrigin(state) == SurveyOrigin.dashboard,
          onReset: onSurveyFinished,
        );
      } else {
        context.pop();
      }
    }

    final page = ResultPage(
      assessmentId: state.pathParameters['assessmentId']!,
      onBack: onBack,
      onRecommendationTap: () => context.push(
        state.uri.replace(path: '${state.uri.path}/recommendations').toString(),
      ),
    );
    if (!fromSurvey) return page;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onBack();
      },
      child: page,
    );
  },
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
