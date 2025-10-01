import 'package:flutter/material.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reels', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          const Text('Upload and manage reels coming soon...'),
        ],
      ),
    );
  }
}

