import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config.dart';
import '../theme.dart';
import 'voice_triage_button.dart';

/// Right-side team channel chat panel. Now includes the main incident
/// reporting input (text + voice) as requested.
class TeamChannelPanel extends StatefulWidget {
  final int? incidentId;
  final VoidCallback onVoiceReportSent;

  const TeamChannelPanel({
    super.key, 
    this.incidentId, 
    required this.onVoiceReportSent
  });

  @override
  State<TeamChannelPanel> createState() => _TeamChannelPanelState();
}

class _TeamChannelPanelState extends State<TeamChannelPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    if (widget.incidentId != null) {
      _fetchMessages();
      _connectWebSocket();
    }
  }

  @override
  void didUpdateWidget(TeamChannelPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incidentId != widget.incidentId) {
      _channel?.sink.close();
      setState(() => _messages = []);
      if (widget.incidentId != null) {
        _fetchMessages();
        _connectWebSocket();
      }
    }
  }

  Future<void> _fetchMessages() async {
    if (widget.incidentId == null) return;
    try {
      final res = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/incident/${widget.incidentId}/chat/'),
      );
      if (res.statusCode == 200 && mounted) {
        setState(() => _messages = json.decode(res.body));
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('TeamChannel fetch error: $e');
    }
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
    _channel!.stream.listen(
      (message) {
        try {
          final data = json.decode(message.toString());
          if (data['event'] == 'chat_message' &&
              data['data']['incident_id'] == widget.incidentId) {
            _fetchMessages();
          }
        } catch (_) {}
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    // If an incident is selected, post as a chat message.
    // If NO incident selected, post as a NEW incident report.
    final url = widget.incidentId != null 
      ? '${AppConfig.baseUrl}/incident/${widget.incidentId}/chat/'
      : '${AppConfig.baseUrl}/incident/';

    try {
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          widget.incidentId != null 
            ? {'sender': 'Staff', 'message': text}
            : {'text': text}
        ),
      );
      if (widget.incidentId == null) {
         widget.onVoiceReportSent(); // Refresh list to show new incident
      }
    } catch (e) {
      debugPrint('TeamChannel send error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBgCard,
        border: Border(left: BorderSide(color: kDivider)),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kDivider)),
            ),
            child: Row(
              children: [
                Text(
                  'TEAM CHANNEL',
                  style: GoogleFonts.rajdhani(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kSevLow,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'ONLINE',
                  style: GoogleFonts.exo2(
                    color: kSevLow,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // ── Message list ───────────────────────────────────────────────
          Expanded(
            child: widget.incidentId == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            color: kAccentDim, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'Select an incident\nto view team chat',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.exo2(
                              color: kTextSecond, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet',
                          style: GoogleFonts.exo2(
                              color: kTextSecond, fontSize: 12),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            _MessageEntry(message: _messages[index]),
                      ),
          ),

          // ── Bottom Input Area ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: const BoxDecoration(
              color: kBgDeep, // Tinted background for the input area
              border: Border(top: BorderSide(color: kDivider)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.exo2(
                            color: kTextPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'DESCRIBE THE SITUATION...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          hintStyle: GoogleFonts.exo2(
                            color: kTextSecond,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                          filled: true,
                          fillColor: kBgCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kDivider),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kAccentCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: kAccentCyan.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.send,
                            color: kAccentCyan, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                VoiceTriageButton(onReportSent: widget.onVoiceReportSent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageEntry extends StatelessWidget {
  final Map<String, dynamic> message;

  const _MessageEntry({required this.message});

  @override
  Widget build(BuildContext context) {
    final sender = message['sender'] as String? ?? 'Unknown';
    final msg    = message['message'] as String? ?? '';
    final senderUp = sender.toUpperCase();
    final isAi = senderUp.contains('NLP') ||
        senderUp.contains('AI') ||
        senderUp.contains('INTEL');

    if (isAi) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kAccentCyan.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kAccentCyan.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, color: kAccentCyan, size: 12),
                const SizedBox(width: 8),
                Text(
                  'NLP INTEL — CORE UPDATED',
                  style: GoogleFonts.shareTechMono(
                    color: kAccentCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: GoogleFonts.shareTechMono(
                color: kTextPrimary.withOpacity(0.9),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                senderUp,
                style: GoogleFonts.exo2(
                  color: kTextSecond,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '22:31', // Placeholder time
                style: GoogleFonts.shareTechMono(
                  color: kTextSecond.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            msg,
            style: GoogleFonts.exo2(
              color: kTextPrimary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: kDivider),
        ],
      ),
    );
  }
}
