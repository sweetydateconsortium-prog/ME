import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          const Text('User list and details coming soon...'),
        ],
      ),
    );
  }
}

