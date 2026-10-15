/// The origin travels with the survey routes, independent of the selected tab.
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
  static const editProfile = '$profile/edit';
  static const preferences = '$profile/preferences';
  static const help = '$profile/help';
  static const about = '$profile/about';
  static const personalization = '$profile/personalization';
  static const dashboardSurvey = '$survey?origin=dashboard';

  static String questionsFor(SurveyOrigin origin) =>
      '$survey/questions${_originQuery(origin)}';

  static String submittedResultFor(SurveyOrigin origin, String id) =>
      '$survey/result/${Uri.encodeComponent(id)}${_originQuery(origin)}';

  static String _originQuery(SurveyOrigin origin) =>
      origin == SurveyOrigin.dashboard ? '?origin=dashboard' : '';

  static String resultFor(String id) =>
      '$history/result/${Uri.encodeComponent(id)}';
}
