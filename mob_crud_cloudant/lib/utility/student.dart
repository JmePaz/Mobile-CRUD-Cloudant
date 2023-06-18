import 'package:flutter/cupertino.dart';

enum Gender { male, female }

final List<String> GENDERS = [
  'Male',
  'Female',
  'Trans man',
  'Trans woman',
  'Non-binary',
  'Not-Listed',
  'Prefered not to disclosed'
];

class Student {
  //text editing controller
  TextEditingController studentIDController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Gender? genderController;
  TextEditingController genderController2 = TextEditingController();

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
    genderController2.text = data['gender'];
  }

  String? getDocId() {
    return _Id;
  }

  String? getDocRev() {
    return _rev;
  }

  void updateRevId(String newRev) {
    _rev = newRev;
  }

  Map exportasMap({isExportIds = false}) {
    int? studentId = int.tryParse(studentIDController.text);
    String name = nameController.text;
    int? age = int.tryParse(ageController.text);
    String gender = genderController2.text;
    String email = emailController.text;
    Map data = {
      'studentId': studentId,
      'name': name,
      'age': age,
      'gender': gender,
      'emailAddress': email
    };

    if (isExportIds) {
      data['_id'] = _Id;
      data['_rev'] = _rev;
    }

    return data;
  }
}
