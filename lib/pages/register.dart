import 'package:flutter/material.dart';
import 'package:ai_calendar/functions/all.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'navigation.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _studentName = TextEditingController();
  final _studentYear = TextEditingController();
  final _studentEmail = TextEditingController();
  final _studentPassword = TextEditingController();
  final _database = Database();

  bool _hidePassword=true;

  Future<void> _verifyRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final loginState = prefs.getBool('loginState');

    if (loginState != null) {
      debugPrint('User is logged in!');
      final route = MaterialPageRoute(
        builder: (context) => const NavigationPage(),
      );
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      resizeToAvoidBottomInset : false,
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

          const SizedBox(height: 15),
          TextFormField(
              controller: _studentName,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
              ],
              decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()
              )
          ),
          const SizedBox(height: 15),
          TextFormField(
              controller: _studentYear,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
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
          const SizedBox(height: 15),
          TextFormField(
              controller: _studentPassword,
              obscureText: _hidePassword,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.password),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(
                            () {
                          _hidePassword = !_hidePassword;
                        },
                      );
                    },
                  ),
              )
          ),
        ],
      ),
    );
  }

  Container _crudButtons() {
    return Container(
      margin: const EdgeInsets.all(25),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () {
                Map<String,dynamic> data = {
                  'Name' : _studentName.text.trim(),
                  'Email' : _studentEmail.text.trim(),
                  'Year' : _studentYear.text.trim(),
                  'Password' : _studentPassword.text.trim(),
                };
                _database.insertStudentData(data);
                Future.delayed(const Duration(milliseconds: 1000), () {
                  _verifyRegistration();
                });
              },
              child: const Text("Complete Registration"),
            ),
          ]
      ),
    );
  }
}