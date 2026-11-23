class StudentModel {
  final String id;
  final String userId;
  final String fullName;
  final String rollNumber;
  final String classId;

  const StudentModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.rollNumber,
    required this.classId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>;

    return StudentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: profile['full_name'] as String,
      rollNumber: json['roll_number'] as String,
      classId: json['class_id'] as String,
    );
  }
}
