import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';

class EnrolledTable extends StatelessWidget {
  EnrolledTable ({super.key});

  final _enrolledSID = TextEditingController();
  final _enrolledCID = TextEditingController();
  final _database = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment'),
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
              controller: _enrolledSID,
              decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.perm_identity),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _enrolledCID,
              decoration: const InputDecoration(
                  labelText: 'CRN',
                  prefixIcon: Icon(Icons.card_membership),
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
                  'S_ID' : _enrolledSID.text,
                  'C_ID' : _enrolledCID.text,
                };
                _database.insertData("Enrolled", "S_ID", _enrolledSID.text, data, false,
                    "Enrolled", "C_ID", _enrolledCID.text);
              },
              child: const Text("Insert"),
            ),
            OutlinedButton(
              onPressed: () {
                Map<String,dynamic> data = {
                  'S_ID' : _enrolledSID.text,
                  'C_ID' : _enrolledCID.text,
                };
                _database.deleteData("Enrolled", "S_ID", _enrolledSID.text, "C_ID", _enrolledCID.text, data);
              },
              child: const Text("Delete"),
            )
          ]
      ),
    );
  }
}
