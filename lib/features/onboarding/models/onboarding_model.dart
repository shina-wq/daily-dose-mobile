class OnboardingModel {
  final String illnessType;
  final List<String> medications;
  final List<String> symptoms;
  final String doctorType;
  final String aiPreference;

  const OnboardingModel({
    required this.illnessType,
    required this.medications,
    required this.symptoms,
    required this.doctorType,
    required this.aiPreference,
  });

  Map<String, dynamic> toMap() {
    return {
      'illnessType': illnessType,
      'medications': medications,
      'symptoms': symptoms,
      'doctorType': doctorType,
      'aiPreference': aiPreference,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
