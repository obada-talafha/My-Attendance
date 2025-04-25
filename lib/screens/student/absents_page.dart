import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsentsPage extends StatelessWidget {
  final List<Map<String, String>> absentDates;
  final String courseTitle;

  const AbsentsPage({Key? key, required this.absentDates, required this.courseTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          courseTitle,
          style: GoogleFonts.jost(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xF5F9FF),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: absentDates.length,
        itemBuilder: (context, index) {
          final absent = absentDates[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                absent["day"] ?? "",
                style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                absent["date"] ?? "",
                style: GoogleFonts.jost(fontSize: 16),
              ),
              leading: Icon(Icons.event_busy, color: Colors.redAccent),
            ),
          );
        },
      ),
    );
  }
}
