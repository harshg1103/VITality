import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/app_provider.dart';
import 'discovery_stack_screen.dart';
import 'matches_screen.dart';
import 'profile_setup_screen.dart';
import 'admin_dashboard.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [DiscoveryStackScreen(), MatchesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)]),
              boxShadow: [BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.5), blurRadius: 10)],
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('VITality', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5,
            foreground: Paint()..shader = const LinearGradient(colors: [Colors.white, Color(0xFFB026FF), Color(0xFF00E5FF)])
                .createShader(const Rect.fromLTWH(0, 0, 120, 28)))),
        ]),
        actions: [
          if (context.watch<AppProvider>().currentUser?.prn == '12413129')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00E5FF)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
              tooltip: 'Admin Dashboard',
            ),
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded, color: Color(0xFFB026FF)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen())),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFA0A0C0)),
            onPressed: () async {
              await context.read<AppProvider>().logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                indicatorColor: const Color(0xFFB026FF).withValues(alpha: 0.3),
                selectedIndex: _index,
                onDestinationSelected: (i) {
                  HapticFeedback.lightImpact();
                  setState(() => _index = i);
                },
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.explore_rounded, color: Color(0xFFA0A0C0)),
                    selectedIcon: Icon(Icons.explore_rounded, color: Color(0xFF00E5FF)),
                    label: 'Discover',
                  ),
                  NavigationDestination(
                    icon: Consumer<AppProvider>(
                      builder: (_, p, __) => Badge(
                        isLabelVisible: p.matches.isNotEmpty,
                        label: Text('${p.matches.length}'),
                        child: const Icon(Icons.favorite_rounded, color: Color(0xFFA0A0C0)),
                      ),
                    ),
                    selectedIcon: const Icon(Icons.favorite_rounded, color: Color(0xFFB026FF)),
                    label: 'Synergies',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
