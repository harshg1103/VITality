import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/peer_profile.dart';


class ProfileCard extends StatelessWidget {
  final PeerProfile peer;
  final bool isTop;

  const ProfileCard({super.key, required this.peer, this.isTop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: _accentColor.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            _buildBackground(),
            _buildGradientOverlay(),
            _buildContent(),
            if (isTop) _buildSwipeHints(),
          ],
        ),
      ),
    );
  }

  Color get _accentColor {
    final colors = [
      const Color(0xFF6C3CE1),
      const Color(0xFFE040FB),
      const Color(0xFF00E5FF),
      const Color(0xFFFF4081),
    ];
    return colors[peer.prn.codeUnitAt(peer.prn.length - 1) % colors.length];
  }

  Widget _buildBackground() {
    if (peer.photoPath.isNotEmpty && File(peer.photoPath).existsSync()) {
      return Positioned.fill(
        child: Image.file(File(peer.photoPath), fit: BoxFit.cover),
      );
    }
    final hue = (peer.prn.hashCode.abs() % 360).toDouble();
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HSLColor.fromAHSL(1, hue, 0.6, 0.2).toColor(),
              HSLColor.fromAHSL(1, (hue + 60) % 360, 0.7, 0.3).toColor(),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.person_rounded, size: 120, color: Colors.white.withValues(alpha: 0.15)),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.95)],
            stops: const [0, 0.3, 0.65, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(peer.name,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentColor.withValues(alpha: 0.6)),
                ),
                child: Text(peer.year, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(peer.branch, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            if (peer.overlappingTags.isNotEmpty) ...[
              Row(children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 4),
                Text('Matches: ', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: peer.overlappingTags.take(4).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(tag, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                )).toList(),
              ),
            ] else ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: peer.tags.take(4).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(tag, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeHints() {
    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
              ),
              child: Row(children: [
                const Icon(Icons.link_rounded, color: Colors.greenAccent, size: 16),
                const SizedBox(width: 4),
                Text('LINK', style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.w800, fontSize: 12)),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
              ),
              child: Row(children: [
                Text('SKIP', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.close_rounded, color: Colors.redAccent, size: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
