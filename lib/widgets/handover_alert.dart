import 'dart:ui';
import 'package:flutter/material.dart';

class HandoverAlert extends StatelessWidget {
  final Color accentColor = const Color(0xFF9CFF00);

  const HandoverAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.8), // Black-Gray Glass
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: accentColor, width: 2), // Neon Outline
        ),
        title: Text(
          "HANDOVER INSTRUCTIONS",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please hand over the found item to the respective office personnel listed below during working hours. Ensure the item is delivered safely.",
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            _adminRow("Hostel", "Respective Wardens"),
            _adminRow("AB1", "Student Welfare Office"),
            _adminRow("AB3", "CSE Dept. Office"),
            _adminRow("Library", "Librarian"),
            _adminRow("Grounds", "Physical Education Dept."),
            const SizedBox(height: 20),
            const Text(
              "Note: You can handover the item to the admin nearest to your current location.",
              style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: Text(
                "UNDERSTOOD",
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

          ),
        ],
      ),
    );
  }

  Widget _adminRow(String zone, String admin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: accentColor, size: 20),
          Text("$zone: ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(child: Text(admin, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}