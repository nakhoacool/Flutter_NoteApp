import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance.collection('notes');
  final user = FirebaseAuth.instance.currentUser;

  String get email => user!.email!;
  Future get isVerified => _store.doc(user!.uid).get().then((value) {
        return value.data()!['user_settings']['isVerified'];
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              // sign out the user
              _auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text('You are logged in with email'),
            Text(email),
            FutureBuilder(
              future: isVerified,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('isVerified: ${snapshot.data}');
                } else {
                  return const Text('user is not verified');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
