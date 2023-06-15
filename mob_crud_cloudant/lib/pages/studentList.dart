import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

List<Widget> getStudRecordsTile() {
  return [
    Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              leading: const Icon(
                Icons.person_pin,
                size: 40,
              ),
              title: const Text('James Michael E. Paz'),
              subtitle: Row(
                children: <Widget>[
                  Container(
                    child: const Text('2020161601'),
                    margin: const EdgeInsets.all(5),
                  ),
                  Text('Male')
                ],
              ))
        ],
      ),
    )
  ];
}

class _StudentListState extends State<StudentList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student List Records")),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: getStudRecordsTile(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {}, child: const Icon(Icons.person_add)),
    );
  }
}
