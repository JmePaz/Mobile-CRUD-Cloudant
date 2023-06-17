import 'package:flutter/cupertino.dart';

enum Gender { male, female }

class Student {
  //text editing controller
  TextEditingController studentIDController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Gender? genderController;

  //
  String? _Id;
  String? _rev;

  Student() {
    _Id = null;
    _rev = null;
  }

  Student.fromJson(Map data) {
    //metadata of docs (need for update or deletion!)
    _Id = data['_id'];
    _rev = data['_rev'];

    //actual data of doc
    studentIDController.text = data['studentId'].toString();
    nameController.text = data['name'];
    ageController.text = data['age'].toString();
    emailController.text = data['emailAddress'];
    genderController = data['gender'] == 'Male'
        ? Gender.male
        : data['gender'] == 'Female'
            ? Gender.female
            : null;
  }

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
