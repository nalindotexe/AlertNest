import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Styled incident card for the left sidebar panel.
class IncidentCard extends StatelessWidget {
  final Map<String, dynamic> incident;
  final bool isSelected;
  final VoidCallback onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.isSelected,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final sev      = incident['severity'] as String? ?? '';
    final type     = incident['type'] as String? ?? 'UNKNOWN';
    final location = incident['location'] as String? ?? '—';
    final status   = incident['status'] as String? ?? 'ACTIVE';
    final isDone   = status == 'RESOLVED';
    final id       = incident['id'];
    final sevColor = _sevColor(sev);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? kBgCardAlt : kBgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? kAccentCyan : kDivider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kAccentCyan.withOpacity(0.14),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left severity stripe
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: sevColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type + severity badge row
                      Row(
                        children: [
                          Icon(_typeIcon(type), size: 13, color: sevColor),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              type.replaceAll('_', ' '),
                              style: GoogleFonts.rajdhani(
                                color: kTextPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _SeverityBadge(severity: sev, color: sevColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 10, color: kTextSecond),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              style: GoogleFonts.exo2(
                                  color: kTextSecond, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // ID + status dot
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'INC-${id.toString().padLeft(3, '0')}',
                            style: GoogleFonts.exo2(
                              color: kAccentDim,
                              fontSize: 9,
                              letterSpacing: 1,
                            ),
                          ),
                          _StatusDot(isDone: isDone),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  final Color color;

  const _SeverityBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = severity.isEmpty ? 'N/A' : severity.substring(0, 3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isDone;

  const _StatusDot({required this.isDone});

  @override
  Widget build(BuildContext context) {
    final color = isDone ? kSevLow : kSevHigh;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          isDone ? 'DONE' : 'ACTIVE',
          style: GoogleFonts.exo2(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}
