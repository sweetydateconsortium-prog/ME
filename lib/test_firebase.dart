import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _authStatus = 'Checking...';
  String _firestoreStatus = 'Checking...';
  List<Map<String, dynamic>> _programs = [];

  @override
  void initState() {
    super.initState();
    _testFirebase();
  }

  Future<void> _testFirebase() async {
    try {
      // Test Firebase Auth
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _authStatus =
            '✅ Auth working - User: ${FirebaseAuth.instance.currentUser?.uid}';
      });

      // Test Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('programs')
          .limit(3)
          .get();

      setState(() {
        _firestoreStatus =
            '✅ Firestore working - Found ${snapshot.docs.length} documents';
        _programs = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': doc.data()['title'] ?? 'No title',
                  'category': doc.data()['category'] ?? 'No category',
                })
            .toList();
      });
    } catch (e) {
      setState(() {
        _authStatus = '❌ Auth failed: $e';
        _firestoreStatus = '❌ Firestore failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Test'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔐 Authentication Status:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(_authStatus),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔥 Firestore Status:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(_firestoreStatus),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_programs.isNotEmpty) ...[
              Text('📺 Sample Programs:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ..._programs
                  .map((program) => Card(
                        child: ListTile(
                          title: Text(program['title']),
                          subtitle: Text(program['category']),
                          leading: Icon(Icons.tv),
                        ),
                      ))
                  .toList(),
            ],
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _testFirebase,
                child: Text('🔄 Test Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
