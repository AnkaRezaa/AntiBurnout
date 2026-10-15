import 'risk_level.dart';

export 'risk_level.dart';

class Assessment {
  const Assessment({
    required this.id,
    required this.riskLevel,
    required this.takenAt,
    this.modelFactors = const [],
    this.answerSummary = const [],
  });

  final String id;
  final RiskLevel riskLevel;
  final DateTime takenAt;

  /// Factors supplied by the assessment service, never inferred by the UI.
  final List<AssessmentFactor> modelFactors;

  /// A summary of submitted answers, distinct from model explanations.
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
