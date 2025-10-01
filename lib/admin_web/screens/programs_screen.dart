import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _addProgramDialog() async {
    final TextEditingController title = TextEditingController();
    final TextEditingController description = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Program'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await _db.collection('programs').add({
                'title': title.text.trim(),
                'description': description.text.trim(),
                'createdAt': DateTime.now().toIso8601String(),
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProgram(String id) async {
    await _db.collection('programs').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Programs', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _addProgramDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Program'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.collection('programs').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No programs.'));
                }
                return SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: [
                      for (final doc in docs)
                        DataRow(cells: [
                          DataCell(Text(doc.data()['title'] ?? '')),
                          DataCell(Text(doc.data()['description'] ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteProgram(doc.id),
                              ),
                            ],
                          )),
                        ]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

