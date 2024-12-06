import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';

class AssignmentTable extends StatelessWidget {
  AssignmentTable({super.key});

  final _assignmentID = TextEditingController();
  final _assignmentTitle = TextEditingController();
  final _assignmentDescription = TextEditingController();
  final _assignmentCourse = TextEditingController();
  final _assignmentDeadline = TextEditingController();
  final _database = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: Column(
          children: [
            _textFields(),
            _crudButtons(context),
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
              controller: _assignmentID,
              decoration: const InputDecoration(
                  labelText: 'Assignment ID',
                  prefixIcon: Icon(Icons.newspaper),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _assignmentTitle,
              decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _assignmentDescription,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _assignmentCourse,
              decoration: const InputDecoration(
                  labelText: 'CRN',
                  prefixIcon: Icon(Icons.class_),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _assignmentDeadline,
              decoration: const InputDecoration(
                  labelText: 'Deadline',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder()
              )
          ),
        ],
      ),
    );
  }

  Container _crudButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () async {
                Map<String,dynamic> data = {
                  'AssignmentID' : _assignmentID.text,
                  'Title' : _assignmentTitle.text,
                  'Description' : _assignmentDescription.text,
                  'Course_No' : _assignmentCourse.text,
                  'Deadline' : _assignmentDeadline.text,
                };
                await _database.insertData("Assignment", "AssignmentID", _assignmentID.text,
                    data, true, 'Course', 'CRN', _assignmentCourse.text, 'Course_No');
                Navigator.pop(context); // Navigate back to the calendar page
              },
              child: const Text("Insert"),
            ),
            OutlinedButton(
              onPressed: () async {
                String condition = _assignmentID.text;
                Map<String,dynamic> data = {
                  'Title' : _assignmentTitle.text,
                  'Description' : _assignmentDescription.text,
                  'Course_No' : _assignmentCourse.text,
                  'Deadline' : _assignmentDeadline.text,
                };
                await _database.updateData("Assignment", condition, "AssignmentID", data, true,
                    'Course', 'CRN', _assignmentCourse.text, 'Course_No');
                Navigator.pop(context); // Navigate back to the calendar page
              },
              child: const Text("Update"),
            ),
            OutlinedButton(
              onPressed: () async {
                await _database.deleteData("Assignment", "AssignmentID", _assignmentID.text);
                Navigator.pop(context); // Navigate back to the calendar page
              },
              child: const Text("Delete"),
            )
          ]
      ),
    );
  }
}
