import 'package:flutter/material.dart';

class NotificationsAdminScreen extends StatelessWidget {
  const NotificationsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          const Text('Send and schedule notifications coming soon...'),
        ],
      ),
    );
  }
}

