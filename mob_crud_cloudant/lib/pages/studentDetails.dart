import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool _isOnUpdate = false;
  bool _hasUpdated = false;

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

  void _deleteRecord() async {
    Navigator.pop(context, 'OK');
    setState(() {
      _isLoading = true;
    });
    Map response = await net.requestDeleteOnURL(
        "student/${student?.getDocId()}", {'rev': student?.getDocRev()});

    if (response.containsKey('ok') && response['ok']) {
      Fluttertoast.showToast(msg: "Deleted Successfully");
      //exit
      Navigator.of(context).pop({"isRefresh": true});
    } else {
      Fluttertoast.showToast(msg: "Failed to delete records");
    }
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
                  filled: true,
                  fillColor: (_isEnabledFields)
                      ? Colors.white
                      : Color.fromARGB(255, 226, 225, 225),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 2020102131',
                  labelText: 'Student ID',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                validator: ValidationForm.validateNonEmptyField,
                controller: student?.nameController,
                enabled: _isEnabledFields,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: (_isEnabledFields)
                      ? Colors.white
                      : Color.fromARGB(255, 226, 225, 225),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. John Doe',
                  labelText: 'Student Name',
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: (_isEnabledFields)
                      ? Colors.white
                      : Color.fromARGB(255, 226, 225, 225),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 18, 20, or 24',
                  labelText: 'Student Age',
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: (_isEnabledFields)
                      ? Colors.white
                      : Color.fromARGB(255, 226, 225, 225),
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
              fillColor: (_isEnabledFields)
                  ? Colors.white
                  : Color.fromARGB(255, 226, 225, 225),
            ),
            Row(children: [
              Expanded(
                  flex: 6,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 5, bottom: 5, right: 5, top: 5),
                      child: ElevatedButton.icon(
                          onPressed: update,
                          icon: Icon(Icons.update),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  (_isOnUpdate)
                                      ? Colors.green
                                      : Colors.blueAccent)),
                          label: Text((_isOnUpdate) ? "Save Changes" : "Update",
                              style: TextStyle(fontSize: 15))))),
              Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text(
                                  "Do you want to delete this record?"),
                              content: const Text(
                                  "This will delete the record permanently."),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: _deleteRecord,
                                  child: const Text('OK'),
                                ),
                              ],
                            )),
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

  void update() async {
    if (!_formKey.currentState!.validate() ||
        student?.genderController2.text == "") {
      return;
    }

    if (student == null) {
      Fluttertoast.showToast(
          msg: "Error occured in retrieving student",
          gravity: ToastGravity.BOTTOM);
      return;
    }

    if (!_isOnUpdate) {
      setState(() {
        _isEnabledFields = true;
        _isOnUpdate = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    //save changes
    Map query = student!.exportasMap(isExportIds: true);
    String bodyQuery = jsonEncode(query);

    Map response = await net.requestPOSTOnURL('student', bodyQuery);
    if (response.containsKey('ok') && response['ok']) {
      //update rev id
      student?.updateRevId(response['rev']);
      _hasUpdated = true;
      //success response
      setState(() {
        _isEnabledFields = false;
        _isOnUpdate = false;
      });

      Fluttertoast.showToast(
          msg: "Updated Successfully", gravity: ToastGravity.BOTTOM);
    } else {
      Fluttertoast.showToast(
          msg: "Unsuccessful to Update. Please try again",
          gravity: ToastGravity.BOTTOM);
    }

    setState(() {
      _isLoading = false;
    });
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
            appBar: AppBar(
              title: const Text("Create Student"),
              leading: IconButton(
                onPressed: () {
                  Map res = {};
                  if (_hasUpdated) {
                    res['isRefresh'] = true;
                  }
                  Navigator.of(context).pop(res);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: Container(
                margin: const EdgeInsets.all(10),
                child: FutureBuilder(
                  future: _studentDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map res = snapshot.data!;
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
