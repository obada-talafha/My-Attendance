import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'InstructorHomePage.dart';

class InstructorProfile extends StatefulWidget {
  const InstructorProfile({super.key});

  @override
  State<InstructorProfile> createState() => _InstructorProfileState();
}

class _InstructorProfileState extends State<InstructorProfile> {
  Map<String, dynamic>? instructor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInstructorProfile();
  }

  Future<void> fetchInstructorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final instructorId = prefs.getString('userId');

    if (instructorId == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('https://my-attendance-1.onrender.com/instructorProfile?instructor_id=$instructorId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          instructor = data['instructor'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  TableRow buildTableRow(String label, dynamic value) {
    String displayValue;

    if (label == 'Birth Date' && value != null) {
      try {
        final parsedDate = DateTime.parse(value);
        displayValue =
        '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
      } catch (e) {
        displayValue = value.toString();
      }
    } else {
      displayValue = value?.toString() ?? '';
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            displayValue,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InstructorHomePage()),
            );
          },
        ),
        title: const Text('Instructor Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : instructor == null
          ? const Center(child: Text('Instructor not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: instructor!['image'] != null
                  ? NetworkImage(instructor!['image'])
                  : const AssetImage('asset/profile_pic.png')
              as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              instructor!['name'] ?? '',
              style: GoogleFonts.jost(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              defaultVerticalAlignment:
              TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                buildTableRow('Birth Date', instructor!['birthdate']),
                buildTableRow('Department', instructor!['department']),
                buildTableRow('College', instructor!['college']),
                buildTableRow('Phone', instructor!['phonenum']),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
