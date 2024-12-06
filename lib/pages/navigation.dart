import 'package:flutter/material.dart';
import 'package:ai_calendar/pages/all.dart';
import 'package:ai_calendar/functions/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int index = 0;
  String assignmentCount = '';
  String courseCount = '';
  String professorCount = '';
  String reminderCount = '';
  String averageAssignmentWeekly = '';
  Map<String, dynamic> stats = {};

  final page = [
    const CalendarPage(),
    const EditPage(),
    const AIPage(),
  ];

  @override
  void initState() {
    super.initState();
    updateStatistics();
    _checkID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(),
        body: page[index],
        bottomNavigationBar: _navigationBar()
    );
  }

  NavigationBar _navigationBar() {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (index) =>
          setState(() => this.index = index),
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar'
        ),
        NavigationDestination(
            icon: Icon(Icons.edit_calendar),
            label: 'Edit'
        ),
        // NavigationDestination(
        //     icon: Icon(Icons.info),
        //     label: 'Edit'
        // ),
        NavigationDestination(
            icon: Icon(Icons.psychology),
            label: 'AI'
        ),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('AI Calendar',
        style: TextStyle(
          color: Colors.black,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          updateStatistics();
          _displayBottomSheet(context);
        },
        icon: const Icon(Icons.info),
      ),
      backgroundColor: Colors.white54,
      elevation: 5,
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton<int>(
          icon: const Icon(Icons.person),
          onSelected: (item) => handleClick(item),
          itemBuilder: (context) => [
            const PopupMenuItem<int>(value: 0, child: Text('Logout')),
            // const PopupMenuItem<int>(value: 1, child: Text('Settings')),
          ],
        ),
      ],
    );
  }

  Future<void> handleClick(int item) async {
    final prefs = await SharedPreferences.getInstance();
    switch (item) {
      case 0:
        prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
    // case 1:
    //   break;
    }
  }
  Future<void> _checkID() async {
    final prefs = await SharedPreferences.getInstance();
    final loginID = prefs.getInt('loginID');
    debugPrint('The login ID is: $loginID');
  }

  Future _displayBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                      'Statistics',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        decoration: TextDecoration.underline,
                      )
                  ),
                  const SizedBox(height: 20),
                  Text(assignmentCount,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )
                  ),
                  Text(courseCount,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )
                  ),
                  Text(professorCount,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )
                  ),
                  Text(reminderCount,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )
                  ),
                  Text(averageAssignmentWeekly,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )
                  ),
                ]
            )
        )
    );
  }

  Future<void> updateStatistics() async {
    final database = Database();
    int assignCountInt = 0;
    int courseCountInt = 0;
    int professorCountInt = 0;
    int reminderCountInt = 0;
    double averageAssignmentWeeklyDouble = 0;

    stats = await database.getStudentStatistics();
    assignCountInt = stats['AssignmentCount'];
    assignmentCount = 'Upcoming assignments: $assignCountInt';

    courseCountInt = stats['CourseCount'];
    courseCount = 'Courses enrolled: $courseCountInt';

    professorCountInt = stats['ProfessorCount'];
    professorCount = 'Professors: $professorCountInt';

    reminderCountInt = stats['ReminderCount'];
    reminderCount = 'Reminders: $reminderCountInt';

    if (stats['AverageAssignmentWeekly'] == null) {
      averageAssignmentWeeklyDouble = 0;
    }
    else {
      averageAssignmentWeeklyDouble = stats['AverageAssignmentWeekly'];
    }
    averageAssignmentWeekly = 'Average assignments per week: $averageAssignmentWeeklyDouble';
  }
}
