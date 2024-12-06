import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ai_calendar/pages/all.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  Future<void> _selectPage() async {
    final prefs = await SharedPreferences.getInstance();
    final loginState = prefs.getBool('loginState');

    if (loginState == null) {
      debugPrint('User is NOT logged in!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
    else {
      debugPrint('User is logged in!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _selectPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Icon(Icons.calendar_month, size: 100),
              _icon(context),
              _title(context),
              _loading(context),
            ]
        ),
      ),
    );
  }

  Container _icon(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 240),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 100),
            // Icon(Icons.psychology, size: 100),
          ],
        )
    );
  }

  Container _title(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: const Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "AI Calendar",
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

  Container _loading(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadingAnimationWidget.discreteCircle(
            color: Colors.black,
            size: 75,
          ),
        ],
      ),
    );
  }
}
