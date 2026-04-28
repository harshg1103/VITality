import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import 'home_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _photoPath;

  final List<String> _allSkills = [
    'Flutter', 'React Native', 'Web3', 'Blockchain', 'UI/UX', 'Firebase',
    'Machine Learning', 'Python', 'Java', 'C++', 'IoT', 'Embedded Systems',
    'Cyber Security', 'Cloud Computing', 'DevOps', 'Android', 'iOS',
    'Data Science', 'AR/VR', 'Game Dev',
  ];

  final List<String> _allHobbies = [
    'Photography', 'Gaming', 'Reading', 'Music', 'Sports', 'Traveling',
    'Cooking', 'Art/Design', 'Writing', 'Fitness'
  ];

  final List<String> _allGoals = [
    'Looking for Hackathon Teammates',
    'Study Group',
    'Social/Collaboration',
    'Research Partner',
    'Project Building',
  ];

  final Set<String> _selectedSkills = {};
  final Set<String> _selectedHobbies = {};
  final Set<String> _selectedGoals = {};

  String _prefGender = 'Any';
  String _prefYear = 'Any';

  bool _showPrefs = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser;
    if (user != null) {
      _bioCtrl.text = user.bio;
      _photoPath = user.photoPath.isEmpty ? null : user.photoPath;
      _selectedSkills.addAll(user.technicalSkills);
      _selectedHobbies.addAll(user.hobbies);
      _selectedGoals.addAll(user.goals);
      _prefGender = user.prefGender;
      _prefYear = user.prefYear;
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xf = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xf != null) setState(() => _photoPath = xf.path);
  }

  Future<void> _save() async {
    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile picture is compulsory.', style: GoogleFonts.outfit()), backgroundColor: Colors.red));
      return;
    }
    if (_selectedSkills.isEmpty || _selectedHobbies.isEmpty || _bioCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill your bio, skills, and hobbies.', style: GoogleFonts.outfit()), backgroundColor: Colors.red));
      return;
    }

    final provider = context.read<AppProvider>();
    final user = provider.currentUser;
    if (user == null) return;
    user.bio = _bioCtrl.text.trim();
    user.photoPath = _photoPath ?? '';
    user.technicalSkills = _selectedSkills.toList();
    user.hobbies = _selectedHobbies.toList();
    user.tags = [..._selectedSkills, ..._selectedHobbies].toList();
    user.goals = _selectedGoals.toList();
    user.prefGender = _prefGender;
    user.prefYear = _prefYear;
    await provider.saveProfile(user);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF05050A),
          image: DecorationImage(
            image: AssetImage('assets/images/mesh_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeaderBar()),
              SliverToBoxAdapter(child: _buildPhotoSection()),
              SliverToBoxAdapter(child: _buildBioSection()),
              SliverToBoxAdapter(child: _buildSkillsSection()),
              SliverToBoxAdapter(child: _buildHobbiesSection()),
              SliverToBoxAdapter(child: _buildGoalsSection()),
              SliverToBoxAdapter(child: _buildPreferencesToggle()),
              if (_showPrefs) SliverToBoxAdapter(child: _buildPreferencesSection()),
              SliverToBoxAdapter(child: _buildSaveButton()),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Node Configuration',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Set up your academic profile & discovery preferences',
            style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 13)),
      ]),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildPhotoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFB026FF), Color(0xFF00E5FF)]),
                  boxShadow: [BoxShadow(color: const Color(0xFFB026FF).withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 4)],
                ),
                child: _photoPath != null
                    ? ClipOval(child: Image.file(File(_photoPath!), fit: BoxFit.cover, width: 120, height: 120))
                    : const Icon(Icons.person_rounded, color: Colors.white, size: 56),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB026FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF05050A), width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: 100.ms, duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildBioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Contextual Heuristics', Icons.notes_rounded),
        const SizedBox(height: 10),
        TextField(
          controller: _bioCtrl,
          maxLines: 3,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tell others about your skills, interests, and what you\'re building...',
            hintStyle: GoogleFonts.outfit(color: const Color(0xFF505070), fontSize: 13),
          ),
        ),
      ]),
    );
  }

  Widget _buildSkillsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Technical Skills', Icons.code_rounded),
        const SizedBox(height: 4),
        Text('Select your tech stack & areas of expertise',
            style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allSkills.map((skill) {
            final selected = _selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: selected,
              onSelected: (v) => setState(() => v ? _selectedSkills.add(skill) : _selectedSkills.remove(skill)),
              selectedColor: const Color(0xFFB026FF).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF00E5FF),
              side: BorderSide(color: selected ? const Color(0xFFB026FF) : Colors.white.withValues(alpha: 0.08)),
              labelStyle: GoogleFonts.outfit(
                color: selected ? Colors.white : const Color(0xFFA0A0C0),
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _buildHobbiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Interests & Hobbies', Icons.palette_rounded),
        const SizedBox(height: 4),
        Text('What do you like to do outside of coding?',
            style: GoogleFonts.outfit(color: const Color(0xFF7070A0), fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allHobbies.map((hobby) {
            final selected = _selectedHobbies.contains(hobby);
            return FilterChip(
              label: Text(hobby),
              selected: selected,
              onSelected: (v) => setState(() => v ? _selectedHobbies.add(hobby) : _selectedHobbies.remove(hobby)),
              selectedColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF00E5FF),
              side: BorderSide(color: selected ? const Color(0xFF00E5FF) : Colors.white.withValues(alpha: 0.08)),
              labelStyle: GoogleFonts.outfit(
                color: selected ? Colors.white : const Color(0xFFA0A0C0),
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _buildGoalsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Collaboration Goals', Icons.rocket_launch_rounded),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allGoals.map((goal) {
            final selected = _selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: selected,
              onSelected: (v) => setState(() => v ? _selectedGoals.add(goal) : _selectedGoals.remove(goal)),
              selectedColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF00E5FF),
              side: BorderSide(color: selected ? const Color(0xFF00E5FF) : const Color(0xFF2A2A4A)),
              labelStyle: GoogleFonts.outfit(
                color: selected ? const Color(0xFF00E5FF) : Colors.white70,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _buildPreferencesToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: () => setState(() => _showPrefs = !_showPrefs),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(children: [
            const Icon(Icons.tune_rounded, color: Color(0xFF00E5FF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Connection Preferences', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Social discovery filters (hidden from others)', style: GoogleFonts.outfit(color: const Color(0xFFA0A0C0), fontSize: 11)),
              ]),
            ),
            Icon(_showPrefs ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: const Color(0xFFB026FF)),
          ]),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFB026FF).withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Preferred Gender / Role:', style: GoogleFonts.outfit(color: const Color(0xFFA0A0C0), fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Any', 'Male', 'Female', 'Non-binary'].map((g) {
              final sel = _prefGender == g;
              return ChoiceChip(
                label: Text(g),
                selected: sel,
                onSelected: (_) => setState(() => _prefGender = g),
                selectedColor: const Color(0xFFE040FB).withValues(alpha: 0.3),
                labelStyle: GoogleFonts.outfit(color: sel ? const Color(0xFFE040FB) : Colors.white70, fontSize: 12),
                side: BorderSide(color: sel ? const Color(0xFFE040FB) : const Color(0xFF2A2A4A)),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text('Preferred Year:', style: GoogleFonts.outfit(color: const Color(0xFF9090B0), fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Any', 'FY', 'SY', 'TY', 'BTech'].map((y) {
              final sel = _prefYear == y;
              return ChoiceChip(
                label: Text(y),
                selected: sel,
                onSelected: (_) => setState(() => _prefYear = y),
                selectedColor: const Color(0xFFE040FB).withValues(alpha: 0.3),
                labelStyle: GoogleFonts.outfit(color: sel ? const Color(0xFFE040FB) : Colors.white70, fontSize: 12),
                side: BorderSide(color: sel ? const Color(0xFFE040FB) : const Color(0xFF2A2A4A)),
              );
            }).toList(),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05);
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: SizedBox(
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
            onPressed: _save,
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            label: Text('Save Profile & Launch', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF6C3CE1), size: 18),
      const SizedBox(width: 8),
      Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    ]);
  }
}
