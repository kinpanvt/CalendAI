import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ai_calendar/functions/all.dart';
import 'package:ai_calendar/pages/assignment_list.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class Assignment {
  final String title;
  const Assignment(this.title);

  @override
  String toString() => title;
}

class _CalendarPageState extends State<CalendarPage> {
  final Database _database = Database();
  Map<DateTime, List<String>> _assignments = {};

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    List<Map<String, dynamic>> assignments = await _database.fetchAssignments();
    Map<DateTime, List<String>> assignmentsMap = {};

    for (var assignment in assignments) {
      DateTime date = assignment['Deadline'];
      if (!assignmentsMap.containsKey(date)) {
        assignmentsMap[date] = [];
      }
      assignmentsMap[date]!.add(assignment['Title'] as String);
    }

    setState(() {
      _assignments = assignmentsMap;
      debugPrint('Assignments Map: $_assignments');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            _calendar(context),
          ],
        ),
      ),
    );
  }

  Container _calendar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2034, 1, 1),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignmentListPage(selectedDate: selectedDay),
                ),
              );
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        events[index] as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    return _assignments[day] ?? [];
  }
}
