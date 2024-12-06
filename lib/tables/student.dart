import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';

class StudentTable extends StatelessWidget {
  StudentTable({super.key});

  final _studentID = TextEditingController();
  final _studentName = TextEditingController();
  final _studentYear = TextEditingController();
  final _studentEmail = TextEditingController();
  final _database = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Table'),
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
              controller: _studentID,
              decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.perm_identity),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _studentName,
              decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _studentYear,
              decoration: const InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _studentEmail,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
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
                  'StudentID' : _studentID.text,
                  'Name' : _studentName.text,
                  'Email' : _studentEmail.text,
                  'Year' : _studentYear.text,
                };
                _database.insertData("Student", "StudentID", _studentID.text, data, true);
              },
              child: const Text("Insert"),
            ),
            OutlinedButton(
              onPressed: () {
                String condition = _studentID.text;
                Map<String,dynamic> data = {
                  'Name' : _studentName.text,
                  'Email' : _studentEmail.text,
                  'Year' : _studentYear.text,
                };
                _database.updateData("Student", condition, "StudentID", data, true);
              },
              child: const Text("Update"),
            ),
            OutlinedButton(
              onPressed: () {
                _database.deleteData("Student", "StudentID", _studentID.text);
              },
              child: const Text("Delete"),
            )
          ]
      ),
    );
  }
}