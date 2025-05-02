import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_Home.dart';
import 'screens/instructor/InstructorHomePage.dart';
import 'screens/student/student_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Role-Based App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/admin': (context) => AdminDashboard(),
        '/instructor': (context) => InstructorHomePage(),
        '/student': (context) => StudentHomePage(),
      },
    );
  }
}
