import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class AssignmentListPage extends StatefulWidget {
  final DateTime selectedDate;

  const AssignmentListPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _AssignmentListPageState createState() => _AssignmentListPageState();
}

class _AssignmentListPageState extends State<AssignmentListPage> {
  final Database _database = Database();
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignmentsForDate();
  }

  Future<void> _fetchAssignmentsForDate() async {
    List<Map<String, dynamic>> assignments = await _database.fetchAssignments();
    String formattedDate = widget.selectedDate.toIso8601String().substring(0, 10);
    debugPrint('Formatted Date: $formattedDate');

    List<Map<String, dynamic>> assignmentsForDate = assignments.where((assignment) {
      DateTime deadline = assignment['Deadline'];
      debugPrint('Checking assignment: ${deadline.toIso8601String()}');
      return deadline.toIso8601String().substring(0, 10) == formattedDate;
    }).toList();

    debugPrint('Assignments for date: $assignmentsForDate');

    setState(() {
      _assignments = assignmentsForDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Convert selected date to local time and format it for display
    String displayDate = DateFormat.yMMMMd().format(widget.selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments on $displayDate'),
      ),
      body: ListView.builder(
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          var assignment = _assignments[index];
          return ListTile(
            title: Text(assignment['Title']),
            subtitle: Text(assignment['Description']),
          );
        },
      ),
    );
  }
}
