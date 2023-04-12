import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'widgets/note_drawer.dart';
import 'widgets/note_grid_view.dart';
import 'widgets/note_list_view.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _auth = FirebaseAuth.instance;
  bool listView = true;
  String sortOption = 'date';

  // get all notes that are trashed is true
  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'date': 'Sort by date'},
      {'title': 'Sort by title'},
    ];
    return Scaffold(
      drawer: DrawerWidget(auth: _auth, title: 'Trash'),
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                listView = !listView;
              });
            },
            icon: Icon(listView ? Icons.grid_view : Icons.list),
          ),
          //Sort button
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                sortOption = value.toString(); // cast value to String
              });
            },
            itemBuilder: (context) {
              return sortOptions
                  .map(
                    (option) => PopupMenuItem(
                      value: option.keys.first.toString(),
                      enabled: sortOption != option.keys.first.toString(),
                      child: Row(
                        children: [
                          Icon(
                            option.keys.first == 'title'
                                ? Icons.title
                                : Icons.calendar_today,
                            color: Colors.blue,
                          ), // icon based on key
                          const SizedBox(width: 8),
                          Text(option.values.first),
                        ],
                      ), // cast key to String
                    ),
                  )
                  .toList();
            },
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
            final notes = data.containsKey('user_notes')
                ? data['user_notes'] as List<dynamic>
                : [];
            final trashedNotes =
                notes.where((note) => note['trashed'] == true).toList();

            if (trashedNotes.isEmpty) {
              return const Center(
                child: Text('There is no deleted notes'),
              );
            } else {
              if (sortOption == 'title') {
                trashedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteA['title']
                      .toString()
                      .toLowerCase()
                      .compareTo(noteB['title'].toString().toLowerCase());
                });
              } else if (sortOption == 'date') {
                trashedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteB['dateModified'].compareTo(noteA['dateModified']);
                });
              }
              return listView
                  ? NoteListView(
                      notes: trashedNotes,
                      title: 'Trash',
                    )
                  : NoteGridView(
                      notes: trashedNotes,
                      title: 'Trash',
                    );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
