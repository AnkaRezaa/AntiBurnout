enum SurveyInputKind { text, choice, duration, counter, minutes, rating }

class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.label,
    this.options = const [],
    this.inputKind = SurveyInputKind.text,
    this.subtitle = '',
    this.tip = '',
    this.reviewLabel = '',
    this.unit = '',
    this.initialAnswer,
    this.maximum = double.infinity,
  });

  final String id;
  final String label;

  final List<String> options;
  final SurveyInputKind inputKind;
  final String subtitle;
  final String tip;
  final String reviewLabel;
  final String unit;
  final String? initialAnswer;
  final double maximum;

  bool isValidAnswer(String? answer) {
    if (answer == null || answer.trim().isEmpty) return false;
    if (options.isNotEmpty) return options.contains(answer);
    if (inputKind == SurveyInputKind.text) return true;
    final number = double.tryParse(answer);
    if (number == null || !number.isFinite || number < 0 || number > maximum) {
      return false;
    }
    return (inputKind != SurveyInputKind.counter &&
            inputKind != SurveyInputKind.minutes) ||
        number == number.roundToDouble();
  }
}
