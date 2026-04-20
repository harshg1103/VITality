import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../models/peer_profile.dart';
import '../widgets/profile_card.dart';
import 'synergy_screen.dart';

class DiscoveryStackScreen extends StatefulWidget {
  const DiscoveryStackScreen({super.key});

  @override
  State<DiscoveryStackScreen> createState() => _DiscoveryStackScreenState();
}

class _DiscoveryStackScreenState extends State<DiscoveryStackScreen> {
  final AppinioSwiperController _ctrl = AppinioSwiperController();
  bool _swiping = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final peers = provider.peerStack;
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF05050A),
                image: DecorationImage(
                  image: AssetImage('assets/images/mesh_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
            ),
            if (peers.isEmpty) _buildEmptyState() else _buildCardStack(peers, provider),
            _buildTopStats(provider),
          ],
        );
      },
    );
  }

  Widget _buildTopStats(AppProvider provider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statBadge(Icons.radar_rounded, '${provider.peerStack.length}', 'Nearby'),
            _statBadge(Icons.favorite_rounded, '${provider.matches.length}', 'Synergies'),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        Icon(icon, color: const Color(0xFFB026FF), size: 16),
        const SizedBox(width: 6),
        Text('$val $label', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildCardStack(List<PeerProfile> peers, AppProvider provider) {
    return Column(
      children: [
        Expanded(
          child: AppinioSwiper(
            controller: _ctrl,
            cardCount: peers.length,
            swipeOptions: const SwipeOptions.symmetric(horizontal: true),
            onSwipeEnd: (prevIndex, targetIndex, activity) async {
              if (_swiping) return;
              _swiping = true;
              try {
                final peer = peers[prevIndex];
                if (activity.direction == AxisDirection.right) {
                  final match = await provider.likePeer(peer);
                  if (match != null && mounted) {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => SynergyScreen(match: match)));
                  }
                } else if (activity.direction == AxisDirection.left) {
                  provider.passPeer(peer);
                }
              } finally {
                if (mounted) setState(() => _swiping = false);
              }
            },
            cardBuilder: (context, index) {
              if (index >= peers.length) return const SizedBox.shrink();
              return ProfileCard(peer: peers[index], isTop: index == 0);
            },
          ),
        ),
        _buildActionButtons(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            icon: Icons.close_rounded,
            color: Colors.redAccent,
            size: 60,
            label: 'Skip',
            onTap: () => _ctrl.swipeLeft(),
          ),
          _actionButton(
            icon: Icons.bolt_rounded,
            color: const Color(0xFF00E5FF),
            size: 44,
            label: 'Super',
            onTap: () => _ctrl.swipeRight(),
          ),
          _actionButton(
            icon: Icons.link_rounded,
            color: Colors.greenAccent,
            size: 60,
            label: 'Link',
            onTap: () => _ctrl.swipeRight(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required double size,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF12121A),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Icon(icon, color: color, size: size * 0.45),
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.outfit(color: const Color(0xFFA0A0C0), fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.02),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Icon(Icons.radar_rounded, color: Color(0xFFB026FF), size: 50),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: const Color(0xFFB026FF).withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text('Scanning for Nodes...', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('No compatible peers discovered nearby.\nEnsure Bluetooth and Location are enabled.',
              style: GoogleFonts.outfit(color: const Color(0xFFA0A0C0), fontSize: 14, height: 1.5),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
