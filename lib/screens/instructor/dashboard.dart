import 'package:flutter/material.dart';

class InstructorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Instructor Dashboard')),
      body: Center(child: Text('Welcome Instructor!')),
    );
  }
}