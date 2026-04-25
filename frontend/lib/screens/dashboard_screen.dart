import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../components/incident_card.dart';
import '../components/incident_detail_panel.dart';
import '../components/team_channel_panel.dart';
import '../config.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _incidents = [];
  late WebSocketChannel _channel;
  bool _isLoading = true;
  Map<String, dynamic>? _selectedIncident;
  late Timer _clockTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
    _fetchIncidents();
    _connectWebSocket();
  }

  void _updateClock() {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _fetchIncidents() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/incidents/'));
      if (response.statusCode == 200) {
        final List<dynamic> fetched = json.decode(response.body);
        setState(() {
          _incidents = fetched;
          _isLoading = false;
          // Keep the selected incident in sync with latest data
          if (_selectedIncident != null) {
            final matches =
                fetched.where((i) => i['id'] == _selectedIncident!['id']);
            _selectedIncident = matches.isNotEmpty ? matches.first : null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching incidents: $e');
      setState(() => _isLoading = false);
    }
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
    _channel.stream.listen((message) {
      _fetchIncidents();
    });
  }

  Future<void> _resolveIncident(int id) async {
    try {
      final response =
          await http.post(Uri.parse('${AppConfig.baseUrl}/incident/$id/resolve/'));
      if (response.statusCode == 200) {
        _fetchIncidents();
      }
    } catch (e) {
      debugPrint('Error resolving: $e');
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _channel.sink.close();
    super.dispose();
  }

  // ── Build helpers ────────────────────────────────────────────────────────

  Widget _buildIncidentList() {
    return Container(
      decoration: const BoxDecoration(
        color: kBgCard,
        border: Border(right: BorderSide(color: kDivider)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kDivider)),
            ),
            child: Row(
              children: [
                Text(
                  'ACTIVE INCIDENTS',
                  style: GoogleFonts.rajdhani(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kSevHigh.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_incidents.length}',
                    style: GoogleFonts.rajdhani(
                      color: kSevHigh,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kAccentCyan, strokeWidth: 2))
                : _incidents.isEmpty
                    ? Center(
                        child: Text(
                          'SYSTEM CLEAR',
                          style: GoogleFonts.shareTechMono(color: kTextSecond, fontSize: 12),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _incidents.length,
                        itemBuilder: (context, index) {
                          final inc = _incidents[index];
                          return IncidentCard(
                            incident: inc,
                            isSelected: _selectedIncident?['id'] == inc['id'],
                            onTap: () => setState(() => _selectedIncident = inc),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPanel() {
    if (_selectedIncident == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, color: kAccentDim, size: 64),
            const SizedBox(height: 16),
            Text(
              'SELECT AN INCIDENT TO VIEW INTEL',
              style: GoogleFonts.shareTechMono(color: kTextSecond, fontSize: 13, letterSpacing: 1),
            ),
          ],
        ),
      );
    }
    return IncidentDetailPanel(
      incident: _selectedIncident!,
      onResolve: () => _resolveIncident(_selectedIncident!['id']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Column(
        children: [
          _TopBar(currentTime: _currentTime),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1100) {
                  return _ThreePanelLayout(
                    leftPanel: _buildIncidentList(),
                    centerPanel: _buildCenterPanel(),
                    rightPanel: TeamChannelPanel(
                      incidentId: _selectedIncident?['id'],
                      onVoiceReportSent: _fetchIncidents,
                    ),
                  );
                } else {
                  // Fallback for smaller screens
                  return _selectedIncident == null
                      ? _buildIncidentList()
                      : Column(
                          children: [
                            Container(
                              height: 40,
                              color: kBgCard,
                              child: TextButton.icon(
                                onPressed: () => setState(() => _selectedIncident = null),
                                icon: const Icon(Icons.arrow_back, size: 16, color: kAccentCyan),
                                label: Text('BACK TO LIST', style: GoogleFonts.exo2(color: kAccentCyan, fontSize: 10)),
                              ),
                            ),
                            Expanded(child: _buildCenterPanel()),
                          ],
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String currentTime;
  const _TopBar({required this.currentTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: kBgCard,
        border: Border(bottom: BorderSide(color: kDivider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: kAccentCyan, size: 24),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: 'ALERT',
                    style: GoogleFonts.rajdhani(
                        color: kTextPrimary, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2)),
                TextSpan(
                    text: 'NEST',
                    style: GoogleFonts.rajdhani(
                        color: kAccentCyan, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('v2.4', style: GoogleFonts.exo2(color: kAccentDim, fontSize: 10)),
          const SizedBox(width: 40),
          // User profile
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kSevHigh.withOpacity(0.5))),
            child: Center(child: Text('A', style: GoogleFonts.rajdhani(color: kSevHigh, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alex Rivera', style: GoogleFonts.exo2(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(border: Border.all(color: kSevHigh.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)),
                child: Text('SECURITY', style: GoogleFonts.exo2(color: kSevHigh, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          // Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: kAccentCyan.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(currentTime, style: GoogleFonts.shareTechMono(color: kAccentCyan, fontSize: 24)),
          ),
        ],
      ),
    );
  }
}

class _ThreePanelLayout extends StatelessWidget {
  final Widget leftPanel;
  final Widget centerPanel;
  final Widget rightPanel;

  const _ThreePanelLayout({required this.leftPanel, required this.centerPanel, required this.rightPanel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: leftPanel),
        Expanded(flex: 5, child: centerPanel),
        Expanded(flex: 3, child: rightPanel),
      ],
    );
  }
}
