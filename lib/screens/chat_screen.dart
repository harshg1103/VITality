import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class ChatScreen extends StatefulWidget {
  final MatchModel match;
  const ChatScreen({super.key, required this.match});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _msgCtrl.clear();
    await context.read<AppProvider>().sendMessage(widget.match, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      appBar: _buildAppBar(widget.match),
      body: Column(
        children: [
          _buildEncryptionBanner(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getMatchMessages(widget.match.matchId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFB026FF)));
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                // Convert docs to a list of messages with timestamps
                final msgs = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'text': data['text'] as String,
                    'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  };
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return _buildMessageList(msgs);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MatchModel match) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: const Color(0xFF05050A).withValues(alpha: 0.7),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFB026FF)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)]),
                ),
                child: match.peerPhotoPath.isNotEmpty && File(match.peerPhotoPath).existsSync()
                    ? ClipOval(child: Image.file(File(match.peerPhotoPath), fit: BoxFit.cover))
                    : const Icon(Icons.person_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(match.peerName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${match.peerYear} · ${match.peerBranch}',
                    style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 11)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildEncryptionBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFB026FF).withValues(alpha: 0.1),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.lock_rounded, color: Color(0xFF00E5FF), size: 14),
        const SizedBox(width: 6),
        Text('End-to-End Encrypted P2P Tunnel', style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildMessageList(List<Map<String, dynamic>> msgs) {
    if (msgs.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2A2A4A), size: 56),
          const SizedBox(height: 12),
          Text('Secure tunnel established.\nSend your first message!',
              style: GoogleFonts.outfit(color: const Color(0xFF505070), fontSize: 14, height: 1.5),
              textAlign: TextAlign.center),
        ]),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: msgs.length,
      itemBuilder: (_, i) {
        final raw = msgs[i]['text'] as String;
        final isMe = raw.startsWith('me:');
        final text = raw.substring(raw.indexOf(':') + 1);
        final timestamp = msgs[i]['timestamp'] as DateTime;
        return _MessageBubble(text: text, isMe: isMe, timestamp: timestamp, index: i);
      },
    );
  }

  Widget _buildInputBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF05050A).withValues(alpha: 0.6),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1)),
          ),
          child: Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Send payload...',
                    hintStyle: GoogleFonts.outfit(color: const Color(0xFF505070), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)]),
                  boxShadow: [BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.4), blurRadius: 16)],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final int index;

  const _MessageBubble({required this.text, required this.isMe, required this.timestamp, required this.index});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(timestamp);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.only(bottom: 6, left: isMe ? 48 : 0, right: isMe ? 0 : 48),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)])
                    : null,
                color: isMe ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 20),
                ),
                border: isMe ? null : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
                boxShadow: isMe
                    ? [BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Text(text, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, height: 1.3)),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(left: isMe ? 0 : 8, right: isMe ? 8 : 0),
              child: Text(timeStr, style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 10, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: 0.1);
  }
}
