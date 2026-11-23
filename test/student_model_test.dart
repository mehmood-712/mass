import 'package:flutter_test/flutter_test.dart';
import 'package:mass/models/student_model.dart';

void main() {
  test('Create a Student object', () {
    const student = StudentModel(
      id: '1',
      userId: 'user_101',
      fullName: 'Ali Ahmed',
      rollNumber: 'MASS-001',
      classId: 'class_01',
    );

    expect(student.fullName, 'Ali Ahmed');
    expect(student.rollNumber, 'MASS-001');
  });

  test('Convert JSON data into StudentModel', () {
    final json = {
      'id': '1',
      'user_id': 'user_101',
      'roll_number': 'MASS-001',
      'class_id': 'class_01',
      'profiles': {'full_name': 'Ali Ahmed'},
    };

    final student = StudentModel.fromJson(json);

    expect(student.id, '1');
    expect(student.userId, 'user_101');
    expect(student.fullName, 'Ali Ahmed');
    expect(student.rollNumber, 'MASS-001');
    expect(student.classId, 'class_01');
  });
}
