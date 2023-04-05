import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/note.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  //   FirebaseFirestore.instance
  //     .collection('notes')
  //     .doc(value.user!.uid)
  //     .set({
  //   'user_profile': {
  //     'email': value.user!.email,
  //     'name': _nameController.text,
  //   },
  //   'user_notes': [
  //     {
  //       'id': DateTime.now().toString(),
  //       'title': 'Welcome to Note App',
  //       'content': 'This is your first note',
  //       'dateCreated': DateTime.now(),
  //       'dateModified': DateTime.now(),
  //     }
  //   ],
  // });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              onPressed: () {
                _auth.signOut();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .doc(_auth.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final notes = data['user_notes'] as List<dynamic>;
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index] as Map<String, dynamic>;
                  return GestureDetector(
                    onTap:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetailScreen(note: Note.fromFirestore(note))));
                    },
                    child: ListTile(
                      title: Text(note['title']),
                      subtitle: Text(note['content']),
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-note');
          },
          child: const Icon(Icons.add),
        ));
  }
}
