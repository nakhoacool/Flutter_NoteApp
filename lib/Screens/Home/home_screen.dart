import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:note_app/screens/Home/widgets/note_widget.dart';
import '../../models/note.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  bool listView = true;
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
            //Search button
            IconButton(onPressed: () {
              Navigator.pushNamed(context, '/search-note');
            }, icon: const Icon(Icons.search)),
            IconButton(
              onPressed: () {
                setState(() {
                  listView = !listView;
                });
              },
              icon: Icon(listView ? Icons.grid_view : Icons.list),
            ),
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
              return notes.isEmpty
                  ? const Center(
                      child: Text('Add some notes'),
                    )
                  : listView
                      ? NoteListView(notes: notes)
                      : NoteGridView(notes: notes);
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

class NoteListView extends StatelessWidget {
  const NoteListView({
    super.key,
    required this.notes,
  });

  final List notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index] as Map<String, dynamic>;
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NoteDetailScreen(note: Note.fromFirestore(note))));
          },
          child: NoteWidget(note: Note.fromFirestore(note)),
        );
      },
    );
  }
}

class NoteGridView extends StatelessWidget {
  const NoteGridView({
    super.key,
    required this.notes,
  });

  final List notes;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        scrollDirection: Axis.vertical,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index] as Map<String, dynamic>;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NoteDetailScreen(note: Note.fromFirestore(note))));
            },
            child: NoteWidget(note: Note.fromFirestore(note)),
          );
        });
  }
}
