import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _CountStatCard(title: 'Total Users', collection: 'users'),
              _CountStatCard(title: 'Programs', collection: 'programs'),
              _CountStatCard(title: 'Reels', collection: 'reels'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountStatCard extends StatelessWidget {
  final String title;
  final String collection;
  const _CountStatCard({required this.title, required this.collection});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection(collection).snapshots(),
            builder: (context, snapshot) {
              final int count = snapshot.data?.docs.length ?? 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

