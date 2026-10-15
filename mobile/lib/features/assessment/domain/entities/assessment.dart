import 'risk_level.dart';

export 'risk_level.dart';

class Assessment {
  const Assessment({
    required this.id,
    required this.riskLevel,
    required this.takenAt,
    this.modelFactors = const [],
    this.answerSummary = const [],
    this.isExample = false,
  });

  final String id;
  final RiskLevel riskLevel;
  final DateTime takenAt;

  /// Identifies static UI examples, never a successful service prediction.
  final bool isExample;

  /// Factors supplied by the assessment service or explicitly marked examples.
  /// The UI never infers model contributions from submitted answers.
  final List<AssessmentFactor> modelFactors;

  /// Submitted answers or explicitly marked examples, distinct from model
  /// explanations.
  final List<AssessmentAnswerSummary> answerSummary;
}

class AssessmentFactor {
  const AssessmentFactor({required this.label});

  final String label;
}

class AssessmentAnswerSummary {
  const AssessmentAnswerSummary({required this.label, required this.value});

  final String label;
  final String value;
}
