import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';

class CourseTable extends StatelessWidget {
  CourseTable({super.key});

  final _courseID = TextEditingController();
  final _courseName = TextEditingController();
  final _courseDepartment = TextEditingController();
  final _professorID = TextEditingController();
  final _database = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: Column(
          children: [
            _textFields(),
            _crudButtons(),
          ]
      ),
    );
  }

  Container _textFields() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        children: [
          TextFormField(
              controller: _courseID,
              decoration: const InputDecoration(
                  labelText: 'CRN',
                  prefixIcon: Icon(Icons.card_membership),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _courseName,
              decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _courseDepartment,
              decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.class_),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _professorID,
              decoration: const InputDecoration(
                  labelText: 'Professor ID',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()
              )
          ),
        ],
      ),
    );
  }

  Container _crudButtons() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () {
                Map<String,dynamic> data = {
                  'CRN' : _courseID.text,
                  'CName' : _courseName.text,
                  'CDepartment' : _courseDepartment.text,
                  'Prof_ID' : _professorID.text,
                };
                _database.insertData("Course", "CRN", _courseID.text, data, true, 'Professor', 'ProfessorID',
                    _professorID.text, 'Prof_ID');
              },
              child: const Text("Insert"),
            ),
            OutlinedButton(
              onPressed: () {
                String condition = _courseID.text;
                Map<String,dynamic> data = {
                  'CName' : _courseName.text,
                  'CDepartment' : _courseDepartment.text,
                  'Prof_ID' : _professorID.text,
                };
                _database.updateData("Course", condition, "CRN", data, true, 'Professor', 'ProfessorID',
                    _professorID.text, 'Prof_ID');
              },
              child: const Text("Update"),
            ),
            OutlinedButton(
              onPressed: () {
                _database.deleteData("Course", "CRN", _courseID.text);
              },
              child: const Text("Delete"),
            )
          ]
      ),
    );
  }
}