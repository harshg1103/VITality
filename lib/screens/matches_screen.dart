import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';
import 'chat_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final matches = provider.matches;
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF05050A),
            image: DecorationImage(
              image: AssetImage('assets/images/mesh_bg.png'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: matches.isEmpty ? _buildEmptyState() : _buildList(matches, context),
        );
      },
    );
  }

  Widget _buildList(List<MatchModel> matches, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: matches.length,
      itemBuilder: (ctx, i) => _MatchTile(match: matches[i], index: i),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.02),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Icon(Icons.favorite_border_rounded, color: Color(0xFFB026FF), size: 40),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.1, duration: 1500.ms, curve: Curves.easeInOut),
        const SizedBox(height: 20),
        Text('No Synergies Yet', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Swipe right on compatible nodes to establish connections.',
            style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 13, height: 1.5),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final MatchModel match;
  final int index;
  const _MatchTile({required this.match, required this.index});

  String get _lastMessage {
    if (match.messages.isEmpty) return 'Tap to open encrypted tunnel';
    final raw = match.messages.last;
    final colon = raw.indexOf(':');
    if (colon == -1) return raw;
    return raw.substring(colon + 1);
  }

  bool get _isLastFromMe => match.messages.isNotEmpty && match.messages.last.startsWith('me:');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)]),
              ),
              child: match.peerPhotoPath.isNotEmpty && File(match.peerPhotoPath).existsSync()
                  ? ClipOval(child: Image.file(File(match.peerPhotoPath), fit: BoxFit.cover))
                  : const Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5FF),
                  border: Border.all(color: const Color(0xFF12121A), width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Row(children: [
          Expanded(child: Text(match.peerName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
          Text(
            DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(match.timestamp)),
            style: GoogleFonts.outfit(color: const Color(0xFF505070), fontSize: 11),
          ),
        ]),
        subtitle: Row(children: [
          if (_isLastFromMe) Text('You: ', style: GoogleFonts.outfit(color: const Color(0xFF9090B0), fontSize: 12)),
          Expanded(
            child: Text(_lastMessage,
                style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        trailing: const Icon(Icons.lock_rounded, color: Color(0xFFB026FF), size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(match: match))),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + (index * 50))).slideX(begin: 0.1, curve: Curves.easeOut);
  }
}
