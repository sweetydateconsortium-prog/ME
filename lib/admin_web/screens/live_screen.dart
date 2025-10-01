import 'package:flutter/material.dart';

class LiveControlScreen extends StatelessWidget {
  const LiveControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Streaming', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Start Live'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Stop Live'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

