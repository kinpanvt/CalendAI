import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';

class ProfessorTable extends StatelessWidget {
  ProfessorTable({super.key});

  final _professorID = TextEditingController();
  final _professorName = TextEditingController();
  final _professorEmail = TextEditingController();
  final _professorDepartment = TextEditingController();
  final _database = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professors'),
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
              controller: _professorID,
              decoration: const InputDecoration(
                  labelText: 'Professor ID',
                  prefixIcon: Icon(Icons.perm_identity),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _professorName,
              decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _professorDepartment,
              decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.class_),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _professorEmail,
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
                  'ProfessorID' : _professorID.text,
                  'PName' : _professorName.text,
                  'PEmail' : _professorEmail.text,
                  'PDepartment' : _professorDepartment.text,
                };
                _database.insertData("Professor", "ProfessorID", _professorID.text, data, true);
              },
              child: const Text("Insert"),
            ),
            OutlinedButton(
              onPressed: () {
                String condition = _professorID.text;
                Map<String,dynamic> data = {
                  'PName' : _professorName.text,
                  'PEmail' : _professorEmail.text,
                  'PDepartment' : _professorDepartment.text,
                };
                _database.updateData("Professor", condition, "ProfessorID", data, true);
              },
              child: const Text("Update"),
            ),
            OutlinedButton(
              onPressed: () {
                _database.deleteData("Professor", "ProfessorID", _professorID.text);
              },
              child: const Text("Delete"),
            )
          ]
      ),
    );
  }
}