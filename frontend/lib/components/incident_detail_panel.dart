import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Center panel: progress stepper, current action callout, description,
/// AI score, and resolve button. Receives pre-fetched incident data.
class IncidentDetailPanel extends StatelessWidget {
  final Map<String, dynamic> incident;
  final VoidCallback onResolve;

  const IncidentDetailPanel({
    super.key,
    required this.incident,
    required this.onResolve,
  });

  static const List<String> _steps = [
    'RECEIVED',
    'ON ROUTE',
    'ARRIVED',
    'ON SCENE',
    'RESOLVED',
  ];

  // Maps backend status strings to a 0-based step index.
  static const Map<String, int> _statusIndex = {
    'PENDING':  0,
    'ON_ROUTE': 1,
    'ARRIVED':  2,
    'ON_SCENE': 3,
    'RESOLVED': 4,
  };

  Color _sevColor(String? sev) {
    switch (sev) {
      case 'HIGH':   return kSevHigh;
      case 'MEDIUM': return kSevMed;
      case 'LOW':    return kSevLow;
      default:       return kTextSecond;
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'FIRE':        return Icons.local_fire_department;
      case 'MEDICAL':     return Icons.medical_services;
      case 'SECURITY':    return Icons.security;
      case 'MAINTENANCE': return Icons.build;
      default:            return Icons.warning_amber;
    }
  }

  String _actionHeadline(String? type, String? status) {
    if (status == 'RESOLVED') return 'INCIDENT RESOLVED';
    switch (type) {
      case 'MEDICAL':     return 'HELP IS COMING';
      case 'FIRE':        return 'FIRE TEAM DISPATCHED';
      case 'SECURITY':    return 'SECURITY EN ROUTE';
      case 'MAINTENANCE': return 'CREW DISPATCHED';
      default:            return 'RESPONDER ASSIGNED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final type       = incident['type'] as String? ?? 'UNKNOWN';
    final sev        = incident['severity'] as String? ?? '';
    final location   = incident['location'] as String? ?? '—';
    final text       = incident['text'] as String? ?? '';
    final status     = incident['status'] as String? ?? 'PENDING';
    final id         = incident['id'];
    final epeScore   = incident['epe_score'];
    final epeReason  = incident['epe_reason'] as String? ?? '';
    final activeStep = _statusIndex[status] ?? 0;
    final sevColor   = _sevColor(sev);
    final isResolved = status == 'RESOLVED';

    return Container(
      color: kBgDeep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kDivider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sevColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sevColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    type == 'MEDICAL' ? Icons.notification_important : _typeIcon(type),
                    color: sevColor, 
                    size: 28
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == 'MEDICAL' ? 'MEDICAL EMERGENCY' : type.replaceAll('_', ' '),
                        style: GoogleFonts.rajdhani(
                          color: kTextPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'INC-${id.toString().padLeft(3, '0')}',
                        style: GoogleFonts.exo2(
                          color: kTextSecond,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                _SeverityChip(severity: sev, color: sevColor),
              ],
            ),
          ),

          // ── Scrollable body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress stepper
                  _ProgressStepper(activeStep: activeStep, steps: _steps),
                  const SizedBox(height: 18),

                  // Current action card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kBgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kDivider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT ACTION',
                          style: GoogleFonts.exo2(
                            color: kTextSecond,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _actionHeadline(type, status),
                          style: GoogleFonts.rajdhani(
                            color: kAccentCyan,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dr. Sarah Chen (Medical) - ETA 2 min',
                          style: GoogleFonts.exo2(color: kTextPrimary, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kAccentCyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kAccentCyan.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, size: 10, color: kAccentCyan),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: GoogleFonts.exo2(color: kAccentCyan, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 10, color: kTextSecond),
                                const SizedBox(width: 4),
                                Text(
                                  '22:07',
                                  style: GoogleFonts.exo2(color: kTextSecond, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Incident description
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kBgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kDivider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INCIDENT DESCRIPTION',
                          style: GoogleFonts.exo2(
                            color: kTextSecond,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          text,
                          style: GoogleFonts.exo2(
                            color: kTextPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        if (epeScore != null) ...[
                          const SizedBox(height: 12),
                          _AiScoreBadge(score: epeScore, reason: epeReason),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Resolve button (hidden once resolved)
                  if (!isResolved) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            title: 'RESPONDER',
                            value: 'Dr. Sarah Chen (Medical)',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _InfoCard(
                            title: 'ETA',
                            value: '2 min',
                            icon: Icons.timer_outlined,
                            valueColor: kAccentCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _EnRouteButton(onResolve: onResolve),
                  ],

                  if (isResolved)
                    Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kSevLow.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kSevLow.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              color: kSevLow, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'INCIDENT RESOLVED',
                            style: GoogleFonts.rajdhani(
                              color: kSevLow,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: kTextSecond),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.exo2(
                  color: kTextSecond,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.exo2(
              color: valueColor ?? kTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnRouteButton extends StatefulWidget {
  final VoidCallback onResolve;
  const _EnRouteButton({required this.onResolve});

  @override
  State<_EnRouteButton> createState() => _EnRouteButtonState();
}

class _EnRouteButtonState extends State<_EnRouteButton> {
  bool _isPressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => setState(() => _isPressing = true),
      onLongPressEnd: (_) => setState(() => _isPressing = false),
      onLongPress: widget.onResolve,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressing ? kAccentCyan : kAccentCyan.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kAccentCyan.withOpacity(_isPressing ? 0.4 : 0.2),
              blurRadius: _isPressing ? 20 : 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EN ROUTE',
              style: GoogleFonts.rajdhani(
                color: kBgDeep,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            Text(
              'HOLD 2S',
              style: GoogleFonts.exo2(
                color: kBgDeep.withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _SeverityChip extends StatelessWidget {
  final String severity;
  final Color color;

  const _SeverityChip({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = severity.isEmpty ? 'N/A' : severity;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _AiScoreBadge extends StatelessWidget {
  final dynamic score;
  final String reason;

  const _AiScoreBadge({required this.score, required this.reason});

  @override
  Widget build(BuildContext context) {
    final numScore = score is num ? score as num : 0.0;
    final isCritical = numScore >= 0.5;
    final color = isCritical ? kSevHigh : kTextSecond;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        '⚡ AI Score: ${numScore.toStringAsFixed(2)}  ·  $reason',
        style: GoogleFonts.exo2(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  final int activeStep;
  final List<String> steps;

  const _ProgressStepper(
      {required this.activeStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    // Generates alternating step nodes and connector lines.
    final itemCount = steps.length * 2 - 1;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: List.generate(itemCount, (i) {
          // Even indices → step node, odd → connector
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            final filled = stepBefore < activeStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 2,
                color: filled ? kAccentCyan : kDivider,
              ),
            );
          }
          final idx = i ~/ 2;
          return _StepNode(
            label: steps[idx],
            isActive: idx == activeStep,
            isCompleted: idx < activeStep,
          );
        }),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepNode(
      {required this.label,
      required this.isActive,
      required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? kAccentCyan
        : isCompleted
            ? kAccentDim
            : kDivider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 40 : 15,
          height: isActive ? 40 : 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? kAccentCyan
                : isCompleted
                    ? kAccentDim
                    : kBgCardAlt,
            border: Border.all(color: color, width: isActive ? 0 : 1.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kAccentCyan.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: isActive
              ? const Icon(Icons.directions_run, size: 20, color: kBgDeep)
              : isCompleted
                  ? const Icon(Icons.check, size: 9, color: kBgDeep)
                  : null,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.exo2(
            color: isActive
                ? kAccentCyan
                : isCompleted
                    ? kAccentDim
                    : kTextSecond,
            fontSize: 7,
            fontWeight:
                isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
