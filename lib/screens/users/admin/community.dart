import 'package:flutter/material.dart';

class Community extends StatelessWidget {
  const Community({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _CommunityTile(
              title: 'Add Incident Type',
              icon: Icons.add_box,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/addIncidentType');
              },
            ),
            _CommunityTile(
              title: 'Review Posts',
              icon: Icons.pending_actions,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/reviewPosts');
              },
            ),
            _CommunityTile(
              title: 'Manage Types',
              icon: Icons.category,
              color: Colors.purple,
              onTap: () {
                // future screen to manage/edit types
              },
            ),
            _CommunityTile(
              title: 'User Reports',
              icon: Icons.people,
              color: Colors.green,
              onTap: () {
                // future screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CommunityTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha((255 * 0.1).round()),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
