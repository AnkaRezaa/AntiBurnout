/// The branch path records the entry point for the entire survey flow.
/// Intermediate pages and tab switches cannot overwrite it.
enum SurveyOrigin { dashboard, surveyTab }

abstract final class RoutePaths {
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const survey = '/survey';
  static const history = '/history';
  static const profile = '/profile';
  static const dashboardSurvey = '$home/survey';

  static String questionsFor(SurveyOrigin origin) => switch (origin) {
    SurveyOrigin.dashboard => '$dashboardSurvey/questions',
    SurveyOrigin.surveyTab => '$survey/questions',
  };

  static String submittedResultFor(SurveyOrigin origin, String id) =>
      '${origin == SurveyOrigin.dashboard ? home : survey}/result/${Uri.encodeComponent(id)}';

  static String resultFor(String id) =>
      '$history/result/${Uri.encodeComponent(id)}';
}
