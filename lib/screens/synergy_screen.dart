import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/match_model.dart';
import 'chat_screen.dart';

class SynergyScreen extends StatelessWidget {
  final MatchModel match;
  const SynergyScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A0A4A), Color(0xFF05050A), Color(0xFF05050A)],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildParticles(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSynergyBadge(),
                    const SizedBox(height: 32),
                    _buildAvatarRow(),
                    const SizedBox(height: 36),
                    Text("Synergy Detected!",
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          foreground: Paint()
                            ..shader = const LinearGradient(colors: [Colors.white, Color(0xFFB026FF), Color(0xFF00E5FF)])
                                .createShader(const Rect.fromLTWH(0, 0, 300, 40)),
                        )).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 12),
                    Text('You and ${match.peerName} are compatible nodes!',
                        style: GoogleFonts.outfit(color: const Color(0xFF9090B0), fontSize: 14, height: 1.5),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    if (match.peerTags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: match.peerTags.take(4).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                          ),
                          child: Text(tag, style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 13, fontWeight: FontWeight.w700)),
                        )).toList(),
                      ),
                      const SizedBox(height: 36),
                    ],
                    _buildButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSynergyBadge() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)]),
        boxShadow: [BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.6), blurRadius: 40, spreadRadius: 8)],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 42),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
      duration: 2.seconds,
      color: Colors.white.withValues(alpha: 0.3),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildAvatarRow() {
    Widget avatar(String photoPath, String name, Color accent) {
      return Column(children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.5)]),
            border: Border.all(color: accent, width: 3),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 16)],
          ),
          child: photoPath.isNotEmpty && File(photoPath).existsSync()
              ? ClipOval(child: Image.file(File(photoPath), fit: BoxFit.cover))
              : const Icon(Icons.person_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 8),
        Text(name.split(' ').first, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        avatar('', 'You', const Color(0xFFB026FF)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const Icon(Icons.favorite_rounded, color: Color(0xFF00E5FF), size: 32),
        ).animate(onPlay: (c) => c.repeat())
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 800.ms)
            .then()
            .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.8, 0.8), duration: 800.ms),
        avatar(match.peerPhotoPath, match.peerName, const Color(0xFF00E5FF)),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)]),
              boxShadow: [
                BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatScreen(match: match))),
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
              label: Text('Open Encrypted Tunnel', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Keep Scanning', style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 14)),
        ),
      ]),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  List<Widget> _buildParticles() {
    final rng = Random(42);
    return List.generate(20, (i) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final size = 2.0 + rng.nextDouble() * 4;
      final color = [const Color(0xFFB026FF), const Color(0xFF00E5FF), Colors.white][i % 3];
      return Positioned(
        left: x * 400,
        top: y * 800,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.6)),
        ).animate(delay: Duration(milliseconds: rng.nextInt(1000)), onPlay: (c) => c.repeat())
            .fadeIn(duration: 1.seconds)
            .then()
            .fadeOut(duration: 1.seconds),
      );
    });
  }
}
