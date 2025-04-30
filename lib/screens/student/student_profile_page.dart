import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  Map<String, dynamic>? student;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentProfile();
  }

  Future<void> fetchStudentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('userId');

    if (studentId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://192.168.56.1:3000/studentProfile?student_id=$studentId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          student = data['student'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  TableRow buildTableRow(String label, dynamic value) {
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
            value?.toString() ?? '',
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
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : student == null
          ? const Center(child: Text('Student not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('asset/profile_pic.png'),
            ),
            const SizedBox(height: 20),
            Text(
              student!['name'] ?? '',
              style: GoogleFonts.jost(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                buildTableRow('ID', student!['student_id'] ?? ''),
                buildTableRow('Email', student!['email'] ?? ''),
                buildTableRow('Birth Date', student!['birthdate'] ?? ''),
                buildTableRow('Major', student!['major'] ?? ''),
                buildTableRow('Academic Lvl', student!['academiclvl'].toString()),
                buildTableRow('Status', student!['status'] ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
