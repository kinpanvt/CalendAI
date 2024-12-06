import 'package:ai_calendar/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:ai_calendar/pages/all.dart';
import 'package:ai_calendar/functions/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _studentEmail = TextEditingController();
  final _studentPassword = TextEditingController();
  final _database = Database();
  bool _hidePassword=true;

  @override
  void initState() {
    super.initState();
    _checkID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Center(
        child: Column(
            children: [
              _title(context),
              _fields(context),
              _buttons(context),
            ]
        ),
      ),
    );
  }

  Container _title(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 285),
      child: const Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Login Page",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Container _fields(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
              controller: _studentEmail,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.perm_identity),
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

  Container _buttons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              Map<String,dynamic> data = {
                'Email' : _studentEmail.text.trim(),
                'Password' : _studentPassword.text.trim(),
              };
              _database.loginStudent(data);
              Future.delayed(const Duration(milliseconds: 1000), () {
                _verifyLogin();
              });

            },
            child: const Text("Login"),
          ),
          const SizedBox(height: 25),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
            child: const Text("New? Register!"),
          ),
        ],
      ),
    );
  }
  Future<void> _verifyLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final loginState = prefs.getBool('loginState');

    if (loginState != null) {
      debugPrint('User is logged in!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationPage()),
      );
    }
  }

  Future<void> _checkID() async {
    final prefs = await SharedPreferences.getInstance();
    final loginID = prefs.getInt('loginID');
    debugPrint('The login ID is: $loginID');
  }
}
