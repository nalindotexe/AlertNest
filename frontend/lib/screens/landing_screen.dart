import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'guest_dashboard_screen.dart';
import '../theme.dart';

/// Atmospheric landing portal with a dual-choice entry for Staff and Guests.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Stack(
        children: [
          // Background Grid Effect
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),
          
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Header
                    const Icon(Icons.security, color: kAccentCyan, size: 64),
                    const SizedBox(height: 24),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ALERT',
                            style: GoogleFonts.rajdhani(
                              color: kTextPrimary,
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 8,
                            ),
                          ),
                          TextSpan(
                            text: 'NEST',
                            style: GoogleFonts.rajdhani(
                              color: kAccentCyan,
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'TERMINAL PROTOCOL ACTIVATED',
                      style: GoogleFonts.shareTechMono(
                        color: kTextSecond,
                        fontSize: 12,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 80),
                    
                    // Choice Cards
                    _PortalChoiceCard(
                      title: 'STAFF OPERATIONS',
                      subtitle: 'Access full-scale admin dashboard & team channels',
                      icon: Icons.dashboard_customize_outlined,
                      accentColor: kAccentCyan,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _PortalChoiceCard(
                      title: 'GUEST EMERGENCY',
                      subtitle: 'Initiate protocol & report medical/fire threats',
                      icon: Icons.emergency_share_outlined,
                      accentColor: kSevHigh,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GuestDashboardScreen()),
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kSevLow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SYSTEM STATUS: OPTIMAL',
                          style: GoogleFonts.shareTechMono(
                            color: kSevLow,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalChoiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _PortalChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_PortalChoiceCard> createState() => _PortalChoiceCardState();
}

class _PortalChoiceCardState extends State<_PortalChoiceCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 500, // Maximum width for desktop/tablet
          constraints: const BoxConstraints(maxWidth: double.infinity),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _isHovering ? widget.accentColor.withOpacity(0.08) : kBgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovering ? widget.accentColor : kDivider.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.rajdhani(
                        color: kTextPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.exo2(
                        color: kTextSecond,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, 
                color: widget.accentColor.withOpacity(_isHovering ? 0.8 : 0.2), 
                size: 16
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kAccentCyan.withOpacity(0.1)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
