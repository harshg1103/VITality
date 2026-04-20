import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF05050A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF05050A),
          title: Text('Admin God-View', style: GoogleFonts.outfit(color: const Color(0xFFB026FF), fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Color(0xFF00E5FF),
            labelColor: Color(0xFF00E5FF),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'All Nodes'),
              Tab(text: 'Match Activity'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsersTab(),
            _ActivityTab(),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFB026FF)));
        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF00E5FF)),
              title: Text(data['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
              subtitle: Text('PRN: ${data['prn']} | Branch: ${data['branch']}', style: const TextStyle(color: Colors.white54)),
              trailing: data['isAdmin'] == true ? const Icon(Icons.security, color: Color(0xFFB026FF)) : null,
            );
          },
        );
      },
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('matches').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFB026FF)));
        final matches = snapshot.data!.docs;
        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final data = matches[index].data() as Map<String, dynamic>;
            return ExpansionTile(
              collapsedIconColor: const Color(0xFFB026FF),
              iconColor: const Color(0xFF00E5FF),
              title: Text('Activity: ${data['peerName']}', style: const TextStyle(color: Colors.white)),
              subtitle: Text('ID: ${data['matchId']}', style: const TextStyle(color: Colors.white54)),
              children: [
                ListTile(
                  title: const Text('Stream messages not fetched in top-level snippet.', style: TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('matches').doc(matches[index].id).delete();
                    },
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
