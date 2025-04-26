import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CreateCoursePage.dart';
import 'view_courses_page.dart';
import 'DeleteCoursePage.dart'; // <<-- Don't forget to import

class CourseManagementPage extends StatelessWidget {
  const CourseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ActionItem> actions = [
      _ActionItem(
        label: 'View and Edit',
        icon: Icons.visibility,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewCoursesPage()),
        ),
      ),
      _ActionItem(
        label: 'Create',
        icon: Icons.add,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateCoursePage()),
        ),
      ),
      _ActionItem(
        label: 'Delete',
        icon: Icons.delete,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DeleteCoursePage()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Courses',
          style: GoogleFonts.jost(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Tablet / Web layout
              return Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: actions
                      .map((action) => SizedBox(
                    width: 240,
                    height: 140,
                    child: _buildActionTile(action),
                  ))
                      .toList(),
                ),
              );
            } else {
              // Mobile layout
              return ListView.separated(
                itemCount: actions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildActionTile(actions[index]),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionTile(_ActionItem action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 32, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                action.label,
                style: GoogleFonts.jost(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class to organize action items
class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _ActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
