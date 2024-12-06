import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';

class ReminderTable extends StatelessWidget {
  ReminderTable({super.key});

  final _notificationID = TextEditingController();
  final _notificationMessage = TextEditingController();
  final _notificationDate = TextEditingController();
  final _notificationTime = TextEditingController();
  final _assignmentID = TextEditingController();
  final _database = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
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
              controller: _notificationID,
              decoration: const InputDecoration(
                  labelText: 'Notification ID',
                  prefixIcon: Icon(Icons.newspaper),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _notificationMessage,
              decoration: const InputDecoration(
                  labelText: 'Message',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _notificationDate,
              decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _notificationTime,
              decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.timelapse),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _assignmentID,
              decoration: const InputDecoration(
                  labelText: 'Assignment ID',
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
                  'NotificationID' : _notificationID.text,
                  'Message' : _notificationMessage.text,
                  'Date' : _notificationDate.text,
                  'Time' : _notificationTime.text,
                  'Assign_ID' : _assignmentID.text,

                };
                _database.insertData("Reminder", "NotificationID", _notificationID.text,
                    data, true, 'Assignment', 'AssignmentID', _assignmentID.text, 'Assign_ID');
              },
              child: const Text("Insert"),
            ),
            OutlinedButton(
              onPressed: () {
                String condition = _notificationID.text;
                Map<String,dynamic> data = {
                  'Message' : _notificationMessage.text,
                  'Date' : _notificationDate.text,
                  'Time' : _notificationTime.text,
                  'Assign_ID' : _assignmentID.text,
                };
                _database.updateData("Reminder", condition, "NotificationID", data, true,
                    'Assignment', 'AssignmentID', _assignmentID.text, 'Assign_ID');
              },
              child: const Text("Update"),
            ),
            OutlinedButton(
              onPressed: () {
                _database.deleteData("Reminder", "NotificationID", _notificationID.text);
              },
              child: const Text("Delete"),
            )
          ]
      ),
    );
  }
}