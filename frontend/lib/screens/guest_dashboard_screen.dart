import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/voice_triage_button.dart';
import '../config.dart';

/// RespondHQ: Clean, Accessible Guest Dashboard for Grand Vista Hotel.
class GuestDashboardScreen extends StatefulWidget {
  const GuestDashboardScreen({super.key});

  @override
  State<GuestDashboardScreen> createState() => _GuestDashboardScreenState();
}

class _GuestDashboardScreenState extends State<GuestDashboardScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final String _roomNumber = "412"; // Could be pulled from config/user state
  
  // RespondHQ Design Tokens
  final Color _bgLight = const Color(0xFFF4F6F9);
  final Color _navy = const Color(0xFF203354);
  final Color _softPink = const Color(0xFFF4C7CC);
  final Color _greyText = const Color(0xFF7D8C9E);

  Future<void> _submitTextReport() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) return;
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/incident/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        _descriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully.')),
        );
      }
    } catch (e) {
      debugPrint('Report Error: $e');
    }
  }

  void _onEmergencyTriggered() {
    // Existing logic for high-priority manual dispatch
    _descriptionController.text = "MANUAL EMERGENCY TRIGGERED - ROOM $_roomNumber";
    _submitTextReport();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Header Section
              Column(
                children: [
                  Text(
                    'AlertNest',
                    style: GoogleFonts.outfit(
                      color: _navy,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Grand Vista Hotel — Room $_roomNumber',
                    style: GoogleFonts.outfit(
                      color: _greyText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 2. Primary Action Card
              GestureDetector(
                onLongPress: _onEmergencyTriggered,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _softPink, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, color: _navy, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        'Report Emergency',
                        style: GoogleFonts.outfit(
                          color: _navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 1,
                        color: _softPink,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'HOLD 2 SECONDS',
                        style: GoogleFonts.shareTechMono(
                          color: _greyText,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // 3. Description / Voice Triage Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DESCRIBE THE SITUATION',
                        style: GoogleFonts.outfit(
                          color: _greyText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: GoogleFonts.outfit(color: _navy, fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Type what's happening...",
                      hintStyle: GoogleFonts.outfit(color: _greyText.withOpacity(0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _navy.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _navy.withOpacity(0.1)),
                      ),
                      // Integrated Voice Triage Button as a suffix icon
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8, top: 40),
                        child: Transform.scale(
                          scale: 0.8,
                          child: VoiceTriageButton(
                            onReportSent: () {
                              _descriptionController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voice report processed.')),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _submitTextReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.description_outlined, size: 20),
                  label: Text(
                    'SUBMIT',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // 5. Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: _navy,
        unselectedItemColor: _greyText,
        showUnselectedLabels: true,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_outlined),
                const SizedBox(height: 4),
                Container(width: 20, height: 2, color: _softPink),
              ],
            ),
            label: 'Report',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'My Reports',
          ),
        ],
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
      ),
    );
  }
}
