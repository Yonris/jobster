import 'package:flutter/material.dart'; // Import the seeker form page
import 'package:jobster/pages/auth/recruiter_registration/recruiter_form_step1.dart';
import 'package:jobster/pages/auth/seeker_registration/seeker_form_step1.dart';

class RoleSelectorPage extends StatefulWidget {
  const RoleSelectorPage({super.key});

  @override
  State<RoleSelectorPage> createState() => _RoleSelectorPageState();
}

class _RoleSelectorPageState extends State<RoleSelectorPage> {
  String? _selectedRole;

  void _selectRole(String role) {
    if (!mounted) return;
    setState(() {
      _selectedRole = role;
    });
  }

  void _goToNextPage() {
    if (_selectedRole == 'seeker') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SeekerFormStep1()),
      );
    } else if (_selectedRole == 'recruiter') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecruiterFormStep1()),
      );
    }
  }

  Widget _buildRoleCard(
    String role,
    IconData icon,
    double cardWidth,
    double cardHeight,
  ) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: cardHeight * 0.4,
              color: isSelected ? Colors.white : Colors.deepPurple,
            ),
            const SizedBox(height: 12),
            Text(
              role[0].toUpperCase() + role.substring(1),
              style: TextStyle(
                fontSize: cardHeight * 0.15,
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define card size relative to screen width/height
    final cardWidth = (screenWidth * 0.3).clamp(150, 300).toDouble();
    final cardHeight = (screenHeight * 0.2).clamp(150, 300).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Are you a Seeker or Recruiter?')),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.05,
        ),
        child: Column(
          children: [
            // Title - takes small vertical space
            Text(
              'Choose your role',
              style: TextStyle(
                fontSize: screenHeight * 0.035,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            // Two cards side by side centered
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoleCard(
                  'seeker',
                  Icons.person_search,
                  cardWidth,
                  cardHeight,
                ),
                _buildRoleCard(
                  'recruiter',
                  Icons.business_center,
                  cardWidth,
                  cardHeight,
                ),
              ],
            ),

            // Spacer to push button down relative to screen height
            SizedBox(
              height: screenHeight * 0.15,
            ), // small spacing instead of Spacer
            // Continue button full width with padding
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: ElevatedButton(
                onPressed: _selectedRole != null ? _goToNextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.deepPurple.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03), // Bottom padding
          ],
        ),
      ),
    );
  }
}
