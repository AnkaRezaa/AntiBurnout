class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.label,
    this.options = const [],
  });

  final String id;
  final String label;

  /// Empty options allow a text answer when supplied by the survey service.
  final List<String> options;
}
