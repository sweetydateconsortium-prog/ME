import 'package:flutter/material.dart';

class SettingsAdminScreen extends StatelessWidget {
  const SettingsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          const Text('Admin settings and API keys coming soon...'),
        ],
      ),
    );
  }
}

