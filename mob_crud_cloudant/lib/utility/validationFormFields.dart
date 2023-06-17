class ValidationForm {
  //validate fields
  static String? validateNonEmptyField(value) {
    if (value == null || value.isEmpty) {
      return 'Invalid empty value';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid empty value';
    } else if (int.tryParse(value) == null) {
      return 'Age should be numeric';
    }

    return null;
  }

  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid empty value';
    } else if (value.length > 11) {
      return 'Invalid length of student id';
    }
    int? studentNum = int.tryParse(value);

    if (studentNum == null) {
      return 'Must only contain numeric';
    }

    return null;
  }
}
