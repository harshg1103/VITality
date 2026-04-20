import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import 'profile_setup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _loginPrn = TextEditingController();
  final _loginPass = TextEditingController();
  final _regPrn = TextEditingController();
  final _regName = TextEditingController();
  final _regPass = TextEditingController();
  String _regGender = 'Male';
  String _regYear = 'FY';
  String _regBranch = 'Computer Engineering';

  bool _loginObscure = true;
  bool _regObscure = true;

  final _branches = [
    'Computer Engineering',
    'Information Technology',
    'Electronics & Telecom',
    'Mechanical Engineering',
    'Civil Engineering',
    'AIDS',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginPrn.dispose();
    _loginPass.dispose();
    _regPrn.dispose();
    _regName.dispose();
    _regPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF05050A), // Solid deep black for cleaner neon contrast
          image: DecorationImage(
            image: AssetImage('assets/images/mesh_bg.png'), // Will add a subtle noise/mesh if available, else plain
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [_buildLoginTab(), _buildRegisterTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFB026FF), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 4),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 36),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'VITality',
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Colors.white, Color(0xFFB026FF), Color(0xFF00E5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 4),
          Text(
            'Academic Collaboration & Social Discovery',
            style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 13),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TabBar(
        controller: _tabs,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [const Color(0xFFB026FF).withValues(alpha: 0.2), const Color(0xFF00E5FF).withValues(alpha: 0.2)],
          ),
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
        ),
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelColor: const Color(0xFF7070A0),
        tabs: const [Tab(text: 'Login Node'), Tab(text: 'Register Node')],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildField(
            controller: _loginPrn,
            label: 'PRN (Node ID)',
            hint: '8-digit PRN',
            icon: Icons.fingerprint_rounded,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 8,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _loginPass,
            label: 'Access Key',
            hint: 'Password',
            icon: Icons.lock_rounded,
            obscure: _loginObscure,
            suffixIcon: IconButton(
              icon: Icon(_loginObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFF7070A0)),
              onPressed: () => setState(() => _loginObscure = !_loginObscure),
            ),
          ),
          const SizedBox(height: 28),
          Consumer<AppProvider>(
            builder: (ctx, prov, _) {
              if (prov.error != null) {
                return Column(children: [
                  _buildErrorBanner(prov.error!),
                  const SizedBox(height: 12),
                ]);
              }
              return const SizedBox.shrink();
            },
          ),
          _buildGradientButton(
            label: 'Authenticate Node',
            icon: Icons.login_rounded,
            onTap: _handleLogin,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildField(controller: _regName, label: 'Full Name', hint: 'Your full name', icon: Icons.person_rounded),
          const SizedBox(height: 14),
          _buildField(
            controller: _regPrn,
            label: 'PRN (Node ID)',
            hint: '8-digit PRN',
            icon: Icons.fingerprint_rounded,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 8,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _regPass,
            label: 'Access Key',
            hint: 'Min. 6 characters',
            icon: Icons.lock_rounded,
            obscure: _regObscure,
            suffixIcon: IconButton(
              icon: Icon(_regObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFF7070A0)),
              onPressed: () => setState(() => _regObscure = !_regObscure),
            ),
          ),
          const SizedBox(height: 14),
          _buildDropdown(
            label: 'Gender / Role',
            icon: Icons.people_rounded,
            value: _regGender,
            items: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
            onChanged: (v) => setState(() => _regGender = v!),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _buildDropdown(
                label: 'Year',
                icon: Icons.calendar_today_rounded,
                value: _regYear,
                items: ['FY', 'SY', 'TY', 'BTech'],
                onChanged: (v) => setState(() => _regYear = v!),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _buildDropdown(
            label: 'Branch',
            icon: Icons.school_rounded,
            value: _regBranch,
            items: _branches,
            onChanged: (v) => setState(() => _regBranch = v!),
          ),
          const SizedBox(height: 28),
          Consumer<AppProvider>(
            builder: (ctx, prov, _) {
              if (prov.error != null) {
                return Column(children: [_buildErrorBanner(prov.error!), const SizedBox(height: 12)]);
              }
              return const SizedBox.shrink();
            },
          ),
          _buildGradientButton(
            label: 'Register',
            icon: Icons.rocket_launch_rounded,
            onTap: _handleRegister,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFB026FF), size: 20),
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF12121A),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB026FF)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Row(children: [
            Icon(icon, color: const Color(0xFFB026FF), size: 18),
            const SizedBox(width: 8),
            Text(e, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
          ]))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return Consumer<AppProvider>(
      builder: (ctx, prov, _) => SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFB026FF), Color(0xFF00E5FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: prov.isLoading ? null : onTap,
            icon: prov.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(icon, color: Colors.white),
            label: Text(prov.isLoading ? 'Processing...' : label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: GoogleFonts.outfit(color: Colors.red, fontSize: 13))),
      ]),
    );
  }

  Future<void> _handleLogin() async {
    context.read<AppProvider>().clearError();
    final prn = _loginPrn.text.trim();
    final pass = _loginPass.text;
    final ok = await context.read<AppProvider>().login(prn: prn, password: pass);
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    }
  }

  Future<void> _handleRegister() async {
    context.read<AppProvider>().clearError();
    final ok = await context.read<AppProvider>().register(
      prn: _regPrn.text.trim(),
      name: _regName.text.trim(),
      password: _regPass.text,
      gender: _regGender,
      year: _regYear,
      branch: _regBranch,
    );
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    }
  }
}
