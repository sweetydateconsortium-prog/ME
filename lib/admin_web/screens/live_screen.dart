import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveControlScreen extends StatefulWidget {
  const LiveControlScreen({super.key});

  @override
  State<LiveControlScreen> createState() => _LiveControlScreenState();
}

class _LiveControlScreenState extends State<LiveControlScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _url = TextEditingController();

  Future<void> _startLive() async {
    await _db.collection('liveStreams').doc('main').set({
      'streamUrl': _url.text.trim(),
      'isActive': true,
      'startedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> _stopLive() async {
    await _db.collection('liveStreams').doc('main').set({
      'isActive': false,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Streaming', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          SizedBox(
            width: 600,
            child: TextField(
              controller: _url,
              decoration: const InputDecoration(labelText: 'HLS Stream URL (m3u8)'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(onPressed: _startLive, child: const Text('Start Live')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _stopLive, child: const Text('Stop Live')),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _db.collection('liveStreams').doc('main').snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final bool active = (data?['isActive'] == true);
              return Row(
                children: [
                  Text('Status: ', style: Theme.of(context).textTheme.titleMedium),
                  Text(active ? 'LIVE' : 'Offline', style: TextStyle(color: active ? Colors.red : Colors.grey, fontWeight: FontWeight.w600)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

