import 'package:flutter/cupertino.dart';

enum Gender { male, female }

class Student {
  //text editing controller
  TextEditingController studentIDController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Gender? genderController;

  Map exportasMap() {
    int? studentId = int.tryParse(studentIDController.text);
    String name = nameController.text;
    int? age = int.tryParse(ageController.text);
    String gender = genderController == Gender.male ? "Male" : "Female";
    String email = emailController.text;

    return {
      'studentId': studentId,
      'name': name,
      'age': age,
      'gender': gender,
      'emailAddress': email
    };
  }
}
