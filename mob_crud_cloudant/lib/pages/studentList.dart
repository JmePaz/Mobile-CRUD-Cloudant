import 'dart:convert';

import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utility/network.dart';
import 'regStudentPage.dart';
import 'studentDetails.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  bool _isLoading = true;

  void ViewStudentDetails(int studentId) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: ((context) => StudentDetailsPage(studentId: studentId))))
        .then((value) {
      Map res = value as Map;
      if (res.containsKey('isRefresh') && res['isRefresh']) {
        setState(() {
          _futureInitTiles = getStudRecordsTile();
        });
      }
    });
  }

  Widget generateCardTile(String name, int studentId, String gender) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              onTap: () {
                ViewStudentDetails(studentId);
              },
              leading: const Icon(
                Icons.person_pin,
                size: 40,
              ),
              title: Text(name),
              subtitle: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Text('$studentId'),
                  ),
                  Text(gender)
                ],
              ))
        ],
      ),
    );
  }

  Future<List<Widget>>? _futureInitTiles;

  @override
  initState() {
    super.initState();
    _futureInitTiles = getStudRecordsTile();
  }

  _gotoAddStudent() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: ((context) => const RegisterStudentPage())))
        .then((value) {
      if (value == null) {
        return;
      }
      Map result = (value as Map);
      if (result.containsKey('refresh') && result['refresh'] == true) {
        setState(() {
          _futureInitTiles = getStudRecordsTile();
        });
      }
    });
  }

  Future<List<Widget>> getStudRecordsTile() async {
    setState(() {
      _isLoading = true;
    });

    List<Widget> recordTile = [];
    Map query = {"selector": {}};
    String bodyQuery = jsonEncode(query);
    Map studRecords = await requestPOSTOnURL('student/_find', bodyQuery);

    setState(() {
      _isLoading = false;
    });
    if (studRecords.containsKey('docs') && studRecords['docs'].length > 0) {
      for (int i = 0; i < studRecords['docs'].length; i++) {
        recordTile.add(generateCardTile(
            studRecords['docs'][i]['name'],
            studRecords['docs'][i]['studentId'],
            studRecords['docs'][i]['gender']));
      }

      return recordTile;
    } else {
      return [const Text("No student records")];
    }
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
          appBar: AppBar(title: const Text("Student List Records")),
          body: FutureBuilder(
            future: _futureInitTiles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return RefreshIndicator(
                    onRefresh: () {
                      setState(() {
                        _futureInitTiles = getStudRecordsTile();
                      });
                      return Future.delayed(Duration(seconds: 1));
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: snapshot.data!,
                    ));
              } else if (snapshot.hasError) {
                return Text(
                    "Error Occured ${snapshot.error}. Please try again. ");
              } else {
                return Container();
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: _gotoAddStudent, child: const Icon(Icons.person_add)),
        ));
  }
}
