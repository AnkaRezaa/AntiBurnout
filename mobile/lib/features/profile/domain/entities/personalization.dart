class Personalization {
  const Personalization({
    this.age = '',
    this.gender = '',
    this.country = '',
    this.education = '',
    this.occupation = '',
    this.employmentStatus = '',
    this.workLocation = '',
    this.smoking = '',
    this.alcohol = '',
    this.income = '',
    this.familyMentalHealthHistory = '',
    this.professionalSupport = '',
  });

  final String age;
  final String gender;
  final String country;
  final String education;
  final String occupation;
  final String employmentStatus;
  final String workLocation;
  final String smoking;
  final String alcohol;
  final String income;
  final String familyMentalHealthHistory;
  final String professionalSupport;

  Personalization copyWith({
    String? age,
    String? gender,
    String? country,
    String? education,
    String? occupation,
    String? employmentStatus,
    String? workLocation,
    String? smoking,
    String? alcohol,
    String? income,
    String? familyMentalHealthHistory,
    String? professionalSupport,
  }) {
    return Personalization(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      workLocation: workLocation ?? this.workLocation,
      smoking: smoking ?? this.smoking,
      alcohol: alcohol ?? this.alcohol,
      income: income ?? this.income,
      familyMentalHealthHistory:
          familyMentalHealthHistory ?? this.familyMentalHealthHistory,
      professionalSupport: professionalSupport ?? this.professionalSupport,
    );
  }
}