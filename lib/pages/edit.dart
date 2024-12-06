import 'package:flutter/material.dart';
import 'package:ai_calendar/tables/all.dart';

class EditPage extends StatelessWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            children: [
              _buttonTable(context),
            ]
        ),
      ),
    );
  }

  Container _buttonTable(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 150, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ElevatedButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => StudentTable()),
          //       );
          //     },
          //     child: const Text('Student Table')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfessorTable()),
                );
              },
              child: const Text('Professors')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CourseTable()),
                );
              },
              child: const Text('Courses')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AssignmentTable()),
                );
              },
              child: const Text('Assignments')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderTable()),
                );
              },
              child: const Text('Reminders')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnrolledTable()),
                );
              },
              child: const Text('Enrollment')),
        ],
      ),
    );
  }
}
