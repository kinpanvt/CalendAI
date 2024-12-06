import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import '../pages/calendar.dart';

class Database {
  late Future<MySqlConnection?> _conn;

  Database() {
    _conn = setupConnection();
  }

  Future<MySqlConnection?> setupConnection() async {
    try {
      final conn = await MySqlConnection.connect(ConnectionSettings(
          host: '${dotenv.env['DB_ADDR']}',
          port: int.parse('${dotenv.env['DB_PORT']}'),
          user: '${dotenv.env['DB_USER']}',
          password: '${dotenv.env['DB_PASS']}',
          db: '${dotenv.env['DB_NAME']}'));
      return conn;
    } catch (e) {
      var message = "Connection failed: $e";
      debugPrint(message);
      sendToast(message);
      if (e is MySqlException) {
        debugPrint('MySQL Error Code: ${e.errorNumber}');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getStudentStatistics() async {
    final connection = await _conn;
    Results? result;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('loginID');

    var stats = <String, dynamic>{};

    // Get the number of future assignments
    result = await connection?.query("SELECT COUNT(*) FROM Assignment AS a "
        "JOIN Enrolled AS e ON a.Course_No = e.C_ID "
        "WHERE e.S_ID = ? AND a.Deadline > CURDATE()", [id]);

    // // Get the number of assignments
    // result = await connection?.query("SELECT COUNT(*) FROM Assignment");
    stats['AssignmentCount'] = result?.first[0];

    // Get the number of courses
    result = await connection?.query("SELECT COUNT(*) FROM Enrolled WHERE S_ID = ?", [id]);
    // result = await connection?.query("SELECT COUNT(*) FROM Course");
    stats['CourseCount'] = result?.first[0];

    // Get the number of professors
    // result = await connection?.query("SELECT COUNT(*) FROM Professor");
    result = await connection?.query("SELECT COUNT(DISTINCT c.Prof_ID) "
        "FROM Enrolled AS e "
        "JOIN Course AS c ON e.C_ID = c.CRN "
        "WHERE e.S_ID = ?", [id]);

    stats['ProfessorCount'] = result?.first[0];

    // Get the number of reminders
    // result = await connection?.query("SELECT COUNT(*) FROM Reminder");
    result = await connection?.query("SELECT COUNT(*) "
        "FROM Reminder AS r "
        "JOIN Assignment AS a ON r.Assign_ID = a.AssignmentID "
        "JOIN Enrolled AS e ON a.Course_No = e.C_ID "
        "WHERE e.S_ID = ?", [id]);

    stats['ReminderCount'] = result?.first[0];

    // Get the number of students
    result = await connection?.query("SELECT COUNT(*) FROM Student");
    stats['StudentCount'] = result?.first[0];

    // // Get the number of enrolled courses
    // result = await connection?.query("SELECT COUNT(*) FROM Enrolled");
    // stats['EnrolledCount'] = result?.first[0];

    // Get the average amount of assignments per week
    // result = await connection?.query("SELECT COUNT(*) / COUNT(DISTINCT WEEK(Deadline)) FROM Assignment");
    result = await connection?.query("SELECT COUNT(*) / COUNT(DISTINCT "
        "WEEK(a.Deadline)) FROM Assignment AS a JOIN Enrolled AS e "
        "ON a.Course_No = e.C_ID WHERE e.S_ID = ?", [id]);

    stats['AverageAssignmentWeekly'] = result?.first[0];

    return stats;
  }


  Future<List<Assignment>> getAssignments(DateTime day) async {
    Results? result;
    final connection = await _conn;
    List<Assignment> assignments = [];
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('loginID');

    result = await connection?.query('SELECT a.AssignmentID, a.Title, a.Description, '
        'a.Course_No, a.Deadline '
        'FROM Assignment a '
        'JOIN Course c ON c.CRN = a.Course_No '
        'JOIN Enrolled e ON e.C_ID = c.CRN '
        'WHERE e.S_ID = ?', [id]);

    if (result == null) {
      return [];
    }
    for (var row in result) {
      DateTime deadline = DateTime.parse(row['Deadline']);

      if (deadline.year == day.year && deadline.month == day.month && deadline.day == day.day) {
        assignments.add(Assignment(row[1]));
      }
    }
    return assignments;
  }

  Future<void> loginStudent(Map<String, dynamic> data) async {
    final connection = await _conn;

    String email = data['Email'];
    String password = data['Password'];
    String table = 'Student';
    String idField = 'StudentID';
    Results? result;

    if (email.isEmpty || password.isEmpty) {
      var message = 'All fields must be filled';
        debugPrint(message);
        sendToast(message);
        return;
    }

    if (!(await checkEmailExists(email))) return;

    result = await connection?.query('SELECT StudentID FROM Student WHERE Email = ? AND Password = ?', [email, password]);
    if (result == null || result.isEmpty) {
      var message = 'Password is incorrect';
      debugPrint(message);
      sendToast(message);
      return;
    }
    Map<String, dynamic> studentData = result.first.fields;
    final id = studentData['StudentID'];
    debugPrint("The studentID of studentData is: $id");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('loginState', true);
    prefs.setInt('loginID', id);
    var message = 'Login successful!';
    debugPrint(message);
    sendToast(message);
  }

  Future<bool> checkEmailExists(String email) async {
    final connection = await _conn;
    Results? result;

    result = await connection?.query('SELECT 1 FROM Student WHERE Email = ?', [email]);
    if (result == null || result.isEmpty) {
      var message = 'Email specified does not exist';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    return true;
  }

  Future<void> insertStudentData(Map<String, dynamic> data) async {
    final connection = await _conn;
    String name = data['Name'];
    String year = data['Year'];
    String email = data['Email'];
    String password = data['Password'];
    String table = 'Student';
    String idField = 'StudentID';
    Results? result;

    if (!(checkName(name))) return;
    if (!(checkYear(year))) return;
    if (!(await checkEmail(email))) return;
    if (!(checkPassword(password))) return;

    result = await connection?.query('SELECT MAX($idField) as nextID FROM $table');
    int id = result?.first["nextID"] + 1;
    data[idField] = id;
    debugPrint('idField: $idField');
    debugPrint('id: $id');

    final String keys = data.keys.join(', ');
    final String values = data.values.map((_) => '?').join(', ');

    try {
      await connection?.query('INSERT INTO $table ($keys) VALUES ($values)',
          data.values.toList());
      var message = ("Registration was successful");
      debugPrint(message);
      sendToast(message);
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('loginState', true);
      prefs.setInt('loginID', id);

    } catch (e) {
      var message = ('Insertion failed: $e');
      debugPrint(message);
      sendToast(message);
    }
  }

  bool checkYear(String year) {
    String message;

    if (year.length != 4) {
      message = 'Enter a valid year';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    return true;
  }

  bool checkName(String name) {
    String message;

    if (name.isEmpty) {
      message = 'Name is required';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    return true;
  }

  bool checkPassword(String password) {
    String message;

    if (password.length <6) {
      message = 'Password must be longer than 6 characters';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      message = 'Uppercase letter is required';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      message = 'Lowercase letter is required';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      message = 'Digit is required';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      message = 'Special character is required';
      debugPrint(message);
      sendToast(message);
      return false;
    }
    return true;
  }

  Future<bool> checkEmail(String email) async {
    final connection = await _conn;
    bool valid = EmailValidator.validate(email);
    Results? result;

    if (valid) {
      result = await connection?.query('SELECT * FROM Student WHERE Email = ?', [email]);
      if (result == null || result.isEmpty) {
        return true;
      }
      else {
        var message = 'Email is already used for another account';
        debugPrint(message);
        sendToast(message);
        return false;
      }
    }
    else {
      var message = 'Email is not valid';
      debugPrint(message);
      sendToast(message);
      return false;
    }
  }

  Future<void> insertData(String table, String idName, String id, Map<String, dynamic> data, bool singleKey, [String? table2, String? idName2, String? id2, String? idNameForeign]) async {
    final connection = await _conn;
    final String keys = data.keys.join(', ');
    final String values = data.values.map((_) => '?').join(', ');

    if (await checkInvalidPrimaryKey(table, idName, id, data, true, singleKey, idName2, id2)) return;
    if (checkAnyEmptyNull(data)) return;
    if (await checkInvalidEmail(table, id, data, true, connection)) return;
    if (await checkInvalidForeignKey(table, idName, id, connection, singleKey, data, table2, idName2, id2, idNameForeign)) return;

    try {
      await connection?.query('INSERT INTO $table ($keys) VALUES ($values)',
          data.values.toList());
      var message = ("Data inserted successfully");
      debugPrint(message);
      sendToast(message);
    } catch (e) {
      var message = ('Insertion failed: $e');
      debugPrint(message);
      sendToast(message);
    }
  }

  Future<void> deleteData(String table, String idName, String id,
      [String? idName2, String? id2, Map<String, dynamic>? data]) async {
    final connection = await _conn;
    Results? result;
    bool singleKey = (idName2 == null || id2 == null);

    if (singleKey) {
      result = await connection?.query('DELETE FROM $table WHERE $idName = $id');
    }
    else {
      if (checkAnyEmptyNull(data!)) return;
      result = await connection?.query('DELETE FROM $table WHERE $idName = $id '
          'AND $idName2 = $id2');
    }
    try {
      if (result?.affectedRows == 0) {
        var message = ('That ID does not exist');
        debugPrint(message);
        sendToast(message);
      } else {
        var message = ('Data deleted successfully');
        debugPrint(message);
        sendToast(message);
      }
    } catch (e) {
      debugPrint('Deletion failed: $e');
    }
  }

  Future<void> updateData(String table, String condition, String conditionName,
      Map<String, dynamic> data, bool singleKey, [String? table2, String? idName2, String? id2,
        String? idNameForeign]) async {
    final connection = await _conn;

    if (checkEmptyID(condition)) return;
    if (await checkInvalidPrimaryKey(table, conditionName, condition, data, false, singleKey)) return;
    if (checkNullAttributes(data)) return;
    if (await checkInvalidForeignKey(table, conditionName, condition, connection, singleKey, data,
        table2, idName2, id2, idNameForeign)) return;
    if (await checkInvalidEmail(table, condition, data, false, connection)) return;
    if (await checkEqualData(connection, table, conditionName, condition, data)) return;

    try {
      final String setClause = data.keys.map((key) => "$key = ?").join(', ');
      final List<dynamic> values = data.values.toList();

      await connection?.query('UPDATE $table SET $setClause WHERE '
          '$conditionName = ?', [ ...values, condition ]
      );
      var message = 'Data updated successfully';
      debugPrint(message);
      sendToast(message);
    } catch (e) {
      debugPrint('Update failed: $e');
      if (e is MySqlException) {
        debugPrint('MySQL Error Code: ${e.errorNumber}');
      }
    }
  }

  Future<bool> checkEqualData(MySqlConnection? connection, String table,
      String conditionName, String condition, Map<String, dynamic> data) async {
    var result = await connection?.query('SELECT * FROM $table WHERE '
        '$conditionName = ?', [ condition ]);

    // If the key doesn't exist, then cancel
    if (result == null || result.isEmpty) {
      return true;
    }

    Map<String, dynamic> currentData = result.first.fields;
    // Replace null or missing values with current data
    data.forEach((key, value) {
      if (value == null || value == '') {
        data[key] = currentData[key];
      }
    });

    /**
     * Removes trailing zeros from date & time
     */
    currentData.forEach((key, value) {
      if (value is DateTime) {
        currentData[key] = DateFormat('yyyy-MM-dd').format(value);
      }
      else if ('$value'.contains(':') && '$value'.contains('.')) {
        List<String> timeParts = '$value'.split('.');
        currentData[key] = timeParts[0];
        }
    });

    bool dataIsEqual = data.keys.every(
            (k) => data[k].toString() == currentData[k]
            .toString());
    if (dataIsEqual) {
      var message = 'Input data was the same. Nothing changed.';
      debugPrint(message);
      sendToast(message);
      return true;
    }
    debugPrint('It was not equal');
    return false;
  }

  bool checkAnyEmptyNull(Map<String, dynamic> data) {
    // Check if any attribute/key is not provided
    if (data.values.any((v) => v == null || v == '')) {
      var message = 'All fields must be filled';
      debugPrint(message);
      sendToast(message);
      return true;
    }
    return false;
  }

  bool checkNullAttributes(Map<String, dynamic> data) {
    // Check if no attributes were provided (primary key is not included in 'data'
    // for update function)
    if (data.values.every((value) => value == null || value == '')) {
      var message = 'No attributes were provided';
      debugPrint(message);
      sendToast(message);
      return true ;
    }
    return false;
  }

  bool checkEmptyID(String condition) {
    // Check if ID is not provided
    if (condition == '') {
      var message = 'ID must be provided';
      debugPrint(message);
      sendToast(message);
      return true;
    }
    return false;
  }

  Future<bool> checkInvalidEmail(String table, String id, Map<String, dynamic> data, bool insert, MySqlConnection? connection) async {
    bool valid;
    String emailField;
    String idField;
    Results? result;

    if ((data['Email'] == '' || data['PEmail'] == '') && !insert) { //ignore email in update function if empty
      debugPrint("Test 2");
      return false;
    }

    if (table == 'Student') {
      emailField = 'Email';
      idField = 'StudentID';
      valid = EmailValidator.validate(data[emailField]);
    }
    else if (table == 'Professor')  {
      emailField = 'PEmail';
      idField = 'ProfessorID';
      valid = EmailValidator.validate(data[emailField]);
    }
    else { //tables without email
      return false;
    }

    if (!valid) {
      var message = 'Email is not valid';
      debugPrint(message);
      sendToast(message);
      return true;
    }

    result = await connection?.query('SELECT * FROM $table WHERE $emailField = ? AND $idField != ?', [data[emailField], data[id]]);

    if (result == null || result.isEmpty) {

      return false;
    }
    else {
      var message = 'Email is already used for another account';
      debugPrint(message);
      sendToast(message);
      return true;
    }
  }

  Future<bool> checkInvalidPrimaryKey(String table, String idName, String id,
      Map<String, dynamic> data, bool insert, bool singleKey, [String? idName2, String? id2]) async {
    final connection = await _conn;
    try {
      Results? result;
      if (singleKey) {
        result = await connection?.query('SELECT * FROM $table '
            'WHERE $idName = ?', [id]);
        if (result == null) {
          if (!insert) { // Update function stops
            return true;
          } // Insert function continues
          return false;
        }
        if (result.isNotEmpty) {
          if (!insert) { // Update function continues
            return false;
          } // Insert function stops
          var message = ("That ID already exists");
          debugPrint(message);
          sendToast(message);
          return true; // ID exists
        }
        if (!insert) { // Update stops; no ID to update
          var message = ("That ID does not exist");
          debugPrint(message);
          sendToast(message);
          return true;
        }
        return false; // Insert continues; available ID to insert
      } else { // Double key
        result = await connection?.query('SELECT * FROM $table WHERE '
            '$idName = ? AND $idName2 = ?', [id, id2]);
        if (result == null || result.isEmpty) {
          return false;
        }
        var message = ("Those IDs already exist");
        debugPrint(message);
        sendToast(message);
        return true;
      }
    }
    catch (e) {
      debugPrint('Error Occurred: $e');
      return true;
    }
  }

  Future<bool> checkInvalidForeignKey(String table, String idName, String id,
      MySqlConnection? connection, bool singleKey, [Map<String, dynamic>? data,
      table2, String? idName2, String? id2, String? idNameForeign]) async {
    String query;
    String query2;
    Results? result;
    Results? result2;

    if (id2 == '' || id2 == null) {
      return false;
    }
    if (singleKey) {
      query = 'SELECT 1 FROM $table2 WHERE $idName2 = ${data?[idNameForeign]}';
      result = await connection?.query(query);

      if (result == null || result.isEmpty) {
        var message = 'Chosen $idName2 does not exist';
        debugPrint(message);
        sendToast(message);
        return true;
      }
      return false;
    }
    else {

      query = 'SELECT 1 FROM Student WHERE StudentID = ${data?['S_ID']}';
      query2 = 'SELECT 1 FROM Course WHERE CRN = ${data?['C_ID']}';
      result = await connection?.query(query);
      result2 = await connection?.query(query2);

      if (result == null || result2 == null) {
        var message = 'Chosen ID(s) do not exist';
        debugPrint(message);
        sendToast(message);
        return true;
      }

      if (result.isEmpty && result2.isEmpty) {
        var message = 'Chosen course and student ID do not exist';
        debugPrint(message);
        sendToast(message);
        return true;
      }
      if (result.isEmpty) {
        var message = 'Chosen student ID does not exist';
        debugPrint(message);
        sendToast(message);
        return true;
      }
      if (result2.isEmpty) {
        var message = 'Chosen course ID does not exist';
        debugPrint(message);
        sendToast(message);
        return true;
      }
    }

    return false;
  }

  void sendToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  void checkValues(Map<String, dynamic> data) {
    debugPrint('============================================================');
    data.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('============================================================');
  }

  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    final connection = await _conn;
    List<Map<String, dynamic>> assignments = [];

    if (connection != null) {
      var results = await connection.query('SELECT * FROM Assignment');
      for (var row in results) {
        Map<String, dynamic> assignment = row.fields;

        assignment.forEach((key, value) {
          if (value is Blob) {
            assignment[key] = String.fromCharCodes(value.toBytes() as Uint8List);
          } else if (key == 'Deadline' && value is String) {
            assignment[key] = DateTime.parse(value);
          }
        });

        assignments.add(assignment);
      }
    }

    debugPrint('Fetched assignments: $assignments');
    return assignments;
  }
}