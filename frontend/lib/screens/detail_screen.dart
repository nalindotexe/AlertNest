import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config.dart';
import '../theme.dart';

/// Mobile/fallback incident detail screen using the AlertNest dark theme.
class DetailScreen extends StatefulWidget {
  final int incidentId;

  const DetailScreen({super.key, required this.incidentId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchChat();
    _connectWebSocket();
  }

  Future<void> _fetchChat() async {
    try {
      final response = await http.get(
          Uri.parse(
              '${AppConfig.baseUrl}/incident/${widget.incidentId}/chat/'));
      if (response.statusCode == 200 && mounted) {
        setState(() => _messages = json.decode(response.body));
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error fetching chat: $e');
    }
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
    _channel.stream.listen((message) {
      try {
        final data = json.decode(message.toString());
        if (data['event'] == 'chat_message' &&
            data['data']['incident_id'] == widget.incidentId) {
          _fetchChat();
        } else if (data['event'] == 'incident_resolved' &&
            data['data']['id'] == widget.incidentId) {
          if (mounted) Navigator.pop(context);
        }
      } catch (_) {}
    });
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    try {
      await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/incident/${widget.incidentId}/chat/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sender': 'Staff', 'message': text}),
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> _resolveIncident() async {
    try {
      await http.post(Uri.parse(
          '${AppConfig.baseUrl}/incident/${widget.incidentId}/resolve/'));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error resolving: $e');
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
    _channel.sink.close();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: AppBar(
        backgroundColor: kBgCard,
        foregroundColor: kTextPrimary,
        elevation: 0,
        title: Text(
          'Incident #${widget.incidentId}',
          style: GoogleFonts.rajdhani(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kDivider),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: kSevLow),
            tooltip: 'Resolve Incident',
            onPressed: _resolveIncident,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: GoogleFonts.exo2(
                          color: kTextSecond, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final sender =
                          msg['sender'] as String? ?? 'Unknown';
                      final senderUp = sender.toUpperCase();
                      final isAi = senderUp.contains('NLP') ||
                          senderUp.contains('AI') ||
                          senderUp.contains('INTEL');
                      return Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAi ? '✦ NLP INTEL' : senderUp,
                              style: GoogleFonts.exo2(
                                color: isAi ? kAccentCyan : kSevMed,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              msg['message'] as String? ?? '',
                              style: GoogleFonts.exo2(
                                color: isAi
                                    ? kTextSecond
                                    : kTextPrimary,
                                fontSize: 13,
                                height: 1.45,
                                fontStyle: isAi
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(
                                height: 1,
                                thickness: 1,
                                color: kDivider),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: kBgCard,
              border: Border(top: BorderSide(color: kDivider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: GoogleFonts.exo2(
                        color: kTextPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Send message...',
                      isDense: true,
                      hintStyle: GoogleFonts.exo2(
                          color: kTextSecond, fontSize: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kAccentCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kAccentCyan.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.send,
                        color: kAccentCyan, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
