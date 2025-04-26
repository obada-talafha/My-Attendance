import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'StudentManagementPage.dart';
import 'coursemanage/course_management_page.dart';
import 'instructor_management_page.dart';
import 'admin_management_page.dart';
import 'admin_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttons = [
      {'title': 'Courses', 'icon': Icons.book},
      {'title': 'Students', 'icon': Icons.group},
      {'title': 'Instructors', 'icon': Icons.school},
      {'title': 'Admins', 'icon': Icons.admin_panel_settings},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      drawer: const AdminDrawer(), // 👈 Add the drawer here
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.jost(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: buttons
                      .map((btn) => SizedBox(
                    width: 240,
                    height: 120,
                    child: _buildDashboardButton(
                      title: btn['title'],
                      iconData: btn['icon'],
                      onTap: () => _navigate(context, btn['title']),
                    ),
                  ))
                      .toList(),
                ),
              );
            } else {
              return ListView.separated(
                itemCount: buttons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildDashboardButton(
                    title: buttons[index]['title'],
                    iconData: buttons[index]['icon'],
                    onTap: () => _navigate(context, buttons[index]['title']),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required String title,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 32, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.jost(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String title) {
    if (title == 'Courses') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CourseManagementPage()),
      );
    } else if (title == 'Students') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentManagementPage()),
      );
    } else if (title == 'Instructors') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const InstructorManagementPage()),
      );
    } else if (title == 'Admins') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminManagementPage()),
      );
    }
  }
}
