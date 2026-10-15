import '../../domain/entities/assessment.dart';

/// Shared static content for previewing the result UI with existing history.
/// These examples do not come from submitted answers or a prediction service.
const exampleAssessmentFactors = [
  AssessmentFactor(label: 'Durasi tidur kurang stabil'),
  AssessmentFactor(label: 'Beban aktivitas cukup tinggi'),
  AssessmentFactor(label: 'Tingkat stres yang meningkat'),
];

const exampleAssessmentAnswerSummary = [
  AssessmentAnswerSummary(label: 'Kualitas tidur', value: 'Cukup'),
  AssessmentAnswerSummary(label: 'Waktu layar', value: '6 jam'),
  AssessmentAnswerSummary(label: 'Durasi tidur', value: '7 jam'),
  AssessmentAnswerSummary(label: 'Konsumsi kopi', value: '2 cangkir'),
  AssessmentAnswerSummary(label: 'Beban aktivitas', value: 'Sedang'),
  AssessmentAnswerSummary(label: 'Meditasi', value: '10 menit'),
  AssessmentAnswerSummary(label: 'Suasana hati', value: '65/100'),
];

Assessment createExampleAssessment({
  required String id,
  required RiskLevel riskLevel,
  required DateTime takenAt,
}) => Assessment(
  id: id,
  riskLevel: riskLevel,
  takenAt: takenAt,
  isExample: true,
  modelFactors: exampleAssessmentFactors,
  answerSummary: exampleAssessmentAnswerSummary,
);
