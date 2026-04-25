import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:record/record.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../theme.dart';

class VoiceTriageButton extends StatefulWidget {
  final VoidCallback onReportSent;

  const VoiceTriageButton({super.key, required this.onReportSent});

  @override
  State<VoiceTriageButton> createState() => _VoiceTriageButtonState();
}

class _VoiceTriageButtonState extends State<VoiceTriageButton> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isListening = false;
  String _text = 'Hold to speak...';
  bool _isSecureContext = true;
  bool _isSending = false; // New state for POST loading

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  void _checkSecurity() {
    // Mobile is considered secure context by default for mic access.
    // On Web, this would need a conditional import to check window.isSecureContext.
    _isSecureContext = true; 
  }

  void _listen() async {
    if (!_isSecureContext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone requires HTTPS or localhost connection.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (!_isListening) {
        if (await _audioRecorder.hasPermission()) {
          setState(() {
             _isListening = true;
             _text = 'Recording Audio...';
          });
          
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.opus),
            path: '', // On web, this creates a Blob URL when stopped. On mobile, handled by library.
          );
        }
      }
    } catch (e) {
      debugPrint('Audio Record Failed: $e');
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _stopAndSend() async {
    if (!_isListening || _isSending) return;

    if (mounted) {
      setState(() {
        _isListening = false;
        _isSending = true;
        _text = 'Translating & Classifying...';
      });
      
      final String? blobUrl = await _audioRecorder.stop();

      if (blobUrl != null && blobUrl.isNotEmpty) {
        _sendToBackend(blobUrl);
      } else {
        setState(() {
           _isSending = false;
           _text = 'Hold to speak...';
        });
      }
    }
  }

  Future<void> _sendToBackend(String pathOrUrl) async {
    try {
      // 1. Fetch bytes from path or web Blob URL
      List<int> audioBytes;
      if (kIsWeb) {
        final responseBlob = await http.get(Uri.parse(pathOrUrl));
        audioBytes = responseBlob.bodyBytes;
      } else {
        // Simple way to read file bytes on mobile without adding 'dart:io' here
        // The record package's path on mobile is a file path.
        final response = await http.get(Uri.parse(pathOrUrl.startsWith('/') ? 'file://$pathOrUrl' : pathOrUrl));
        audioBytes = response.bodyBytes;
      }

      // 2. Transmit as Multipart Form Data to /incident/audio/
      var request = http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}/incident/audio/'));
      request.files.add(http.MultipartFile.fromBytes('audio', audioBytes, filename: 'voice_memo.webm'));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        widget.onReportSent();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio Translated & Sent!'), backgroundColor: Colors.green),
        );
      } else {
        print('Backend Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error sending audio report: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _text = 'Hold to speak...';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isListening || _isSending)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kAccentCyan.withOpacity(0.4)),
            ),
            child: Text(
              _isSending ? 'CLASSIFYING...' : 'RECORDING...',
              style: TextStyle(
                color: _isSending ? kSevMed : kAccentCyan,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        AvatarGlow(
          animate: _isListening,
          glowColor: kAccentCyan,
          duration: const Duration(milliseconds: 2000),
          repeat: true,
          child: GestureDetector(
            onLongPressStart: _isSending ? null : (_) => _listen(),
            onLongPressEnd: _isSending ? null : (_) => _stopAndSend(),
            onLongPressUp: _isSending ? null : () => _stopAndSend(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? kSevHigh.withOpacity(0.25)
                    : _isSending
                        ? kDivider
                        : kAccentCyan.withOpacity(0.12),
                border: Border.all(
                  color: _isListening
                      ? kSevHigh
                      : _isSending
                          ? kTextSecond
                          : kAccentCyan.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                          color: kAccentCyan, strokeWidth: 2),
                    )
                  : Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? kSevHigh : kAccentCyan,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
