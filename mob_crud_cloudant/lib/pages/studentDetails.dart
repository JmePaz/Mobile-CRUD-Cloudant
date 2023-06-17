import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import '../utility/student.dart';
import '../utility/network.dart' as net;
import '../utility/validationFormFields.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class StudentDetailsPage extends StatefulWidget {
  final int studentId;
  const StudentDetailsPage({super.key, required this.studentId});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Student? student;
  bool _isGenderError = false;
  Future<Map?>? _studentDetails;
  bool _isEnabledFields = false;

  @override
  initState() {
    super.initState();
    _studentDetails = _fetchDetails();
  }

  Future<Map?> _fetchDetails() async {
    setState(() {
      _isLoading = true;
    });

    int studentId = widget.studentId;
    Map query = {
      'selector': {'studentId': studentId}
    };
    String bodyQuery = jsonEncode(query);
    Map studRecords = await net.requestPOSTOnURL('student/_find', bodyQuery);

    setState(() {
      _isLoading = false;
    });

    if ((studRecords.containsKey('bookmark') &&
            studRecords['bookmark'] == "nil") ||
        (studRecords.containsKey('docs') && studRecords['docs'].length == 0)) {
      return {"ok": false};
    }

    student = Student.fromJson(studRecords['docs'][0]);

    return {'ok': true};
  }

  Widget createForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                validator: ValidationForm.validateStudentId,
                controller: student?.studentIDController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11)
                ],
                enabled: _isEnabledFields,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 2020102131',
                  labelText: 'Enter Student ID',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                validator: ValidationForm.validateNonEmptyField,
                controller: student?.nameController,
                enabled: _isEnabledFields,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. John Doe',
                  labelText: 'Enter Student Name',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                validator: ValidationForm.validateAge,
                keyboardType: TextInputType.number,
                controller: student?.ageController,
                enabled: _isEnabledFields,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2)
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 18, 20, or 24',
                  labelText: 'Enter Student Age',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                validator: ValidationForm.validateNonEmptyField,
                keyboardType: TextInputType.emailAddress,
                controller: student?.emailController,
                enabled: _isEnabledFields,
                decoration: const InputDecoration(
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
            CustomDropdown(
              items: (_isEnabledFields)
                  ? GENDERS
                  : [student!.genderController2.text],
              controller: student!.genderController2,
            ),
            Row(children: [
              Expanded(
                  flex: 6,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 5, bottom: 5, right: 5, top: 5),
                      child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.update),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ))),
                          label: const Text("Update",
                              style: TextStyle(fontSize: 15))))),
              Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.delete_forever),
                    label: Text("delete"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                  ))
            ]),
          ],
        ),
      ),
    );
  }

  void _goToStudentList() {
    Navigator.of(context).pop({'refresh': true});
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
        inAsyncCall: _isLoading,
        blurEffectIntensity: 4,
        progressIndicator: const SpinKitThreeBounce(
          color: Colors.blueAccent,
        ),
        child: Scaffold(
            appBar: AppBar(title: const Text("Create Student")),
            body: Container(
                margin: const EdgeInsets.all(10),
                child: FutureBuilder(
                  future: _studentDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map res = snapshot.data! as Map;
                      if (snapshot.hasData && res['ok']) {
                        return createForm();
                      } else {
                        return const Center(
                            child: Text(
                          "No Record was found",
                          style: TextStyle(fontSize: 25),
                        ));
                      }
                    } else {
                      return Container();
                    }
                  },
                ))));
  }
}
