import 'package:flutter/material.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Programs', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          const Text('Table view coming soon...'),
        ],
      ),
    );
  }
}

