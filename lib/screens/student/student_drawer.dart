import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'student_profile_page.dart';

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFEAF3FF),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 40),
            buildDrawerItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentProfilePage(),
                  ),
                );
              },
            ),
            buildDrawerItem(
              icon: Icons.format_paint_outlined,
              label: 'Theme',
              onTap: null, // Disabled
            ),
            buildDrawerItem(
              icon: Icons.language,
              label: 'Language',
              onTap: null, // Disabled
            ),
            const Spacer(),
            buildDrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () async {
                Navigator.pop(context);
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isLogout = false,
  }) {
    final bool isDisabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isLogout ? Border.all(color: Colors.red) : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red : isDisabled ? Colors.grey : Colors.black,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.jost(
                    fontSize: 16,
                    color: isLogout ? Colors.red : isDisabled ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isDisabled)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isLogout ? Colors.red : Colors.black,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
