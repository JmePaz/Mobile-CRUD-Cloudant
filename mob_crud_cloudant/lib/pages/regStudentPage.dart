import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import '../utility/student.dart';
import '../utility/network.dart';
import '../utility/validationFormFields.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class RegisterStudentPage extends StatefulWidget {
  const RegisterStudentPage({super.key});

  @override
  State<RegisterStudentPage> createState() => _RegisterStudentPageState();
}

class _RegisterStudentPageState extends State<RegisterStudentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Student newStudent = Student();
  bool _isGenderError = false;

  void _goToStudentList() {
    Navigator.of(context).pop({'refresh': true});
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });
    //show loading
    await Future.delayed(const Duration(seconds: 1));

    if (!_formKey.currentState!.validate() ||
        newStudent.genderController2.text == "") {
      setState(() {
        _isLoading = false;
      });
      if (newStudent.genderController2.text == "") {
        setState(() {
          _isGenderError = true;
        });
      }
      return;
    }

    Map query = newStudent.exportasMap();

    String body = jsonEncode(query);
    var response = await requestPOSTOnURL('student', body);
    if (response.containsKey('ok') && response['ok']) {
      Fluttertoast.showToast(
          msg: "Created Successfully", gravity: ToastGravity.BOTTOM);
      _goToStudentList();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
        inAsyncCall: _isLoading,
        blurEffectIntensity: 4,
        progressIndicator: SpinKitThreeBounce(
          color: Colors.blueAccent,
        ),
        child: Scaffold(
            appBar: AppBar(title: const Text("Create Student")),
            body: Container(
                margin: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            validator: ValidationForm.validateStudentId,
                            controller: newStudent.studentIDController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11)
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 2020102131',
                              labelText: 'Enter Student ID',
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            validator: ValidationForm.validateNonEmptyField,
                            controller: newStudent.nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'e.g. John Doe',
                              labelText: 'Enter Student Name',
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            validator: ValidationForm.validateAge,
                            keyboardType: TextInputType.number,
                            controller: newStudent.ageController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2)
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 18, 20, or 24',
                              labelText: 'Enter Student Age',
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            validator: ValidationForm.validateNonEmptyField,
                            keyboardType: TextInputType.emailAddress,
                            controller: newStudent.emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'e.g. johndoe@gmail.com',
                              labelText: 'Enter Email Address',
                            ),
                          ),
                        ),
                        Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "Gender",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            )),
                        (_isGenderError)
                            ? Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(left: 20),
                                child: const Text(
                                  "Please pick a gender",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.redAccent),
                                ))
                            : Container(),
                        CustomDropdown(
                          items: GENDERS,
                          hintText: "Choose a gender",
                          controller: newStudent.genderController2,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, bottom: 5, right: 5, top: 0),
                                child: ElevatedButton(
                                    onPressed: _signUp,
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ))),
                                    child: const Text("Sign Up",
                                        style: TextStyle(fontSize: 15)))))
                      ],
                    ),
                  ),
                ))));
  }
}
