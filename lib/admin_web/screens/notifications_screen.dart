import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsAdminScreen extends StatefulWidget {
  const NotificationsAdminScreen({super.key});

  @override
  State<NotificationsAdminScreen> createState() => _NotificationsAdminScreenState();
}

class _NotificationsAdminScreenState extends State<NotificationsAdminScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _message = TextEditingController();
  final TextEditingController _targetUserId = TextEditingController();
  bool _submitting = false;

  Future<void> _send() async {
    setState(() { _submitting = true; });
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final String userId = _targetUserId.text.trim();
      if (userId.isEmpty) {
        // Create in-app notification for all users: naive approach (requires backend for scale)
        final users = await db.collection('users').get();
        final batch = db.batch();
        for (final u in users.docs) {
          final ref = db.collection('notifications').doc();
          batch.set(ref, {
            'userId': u.id,
            'title': _title.text.trim(),
            'message': _message.text.trim(),
            'type': 'general',
            'read': false,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
        await batch.commit();
      } else {
        await db.collection('notifications').add({
          'userId': userId,
          'title': _title.text.trim(),
          'message': _message.text.trim(),
          'type': 'general',
          'read': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification(s) created')));
        _title.clear();
        _message.clear();
        _targetUserId.clear();
      }
    } finally {
      if (mounted) setState(() { _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          SizedBox(
            width: 700,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: 8),
                    TextField(controller: _message, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
                    const SizedBox(height: 8),
                    TextField(controller: _targetUserId, decoration: const InputDecoration(labelText: 'Target User ID (leave empty for all)')),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _submitting ? null : _send,
                        child: _submitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

