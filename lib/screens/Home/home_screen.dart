import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '/screens/Home/widgets/note_grid_view.dart';
import '/screens/Home/widgets/note_list_view.dart';
import 'widgets/note_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  bool listView = true;
  String sortOption = 'date';
  //   FirebaseFirestore.instance
  //     .collection('notes')
  //     .doc(value.user!.uid)
  //     .set({
  //   'user_profile': {
  //     'email': value.user!.email,
  //     'name': _nameController.text,
  //      'tags': [
  //      'Important',
  //     'Work',
  //    'Personal',],
  //   },
  //   'user_notes': [
  //     {
  //       'id': DateTime.now().toString(),
  //       'title': 'Welcome to Note App',
  //       'content': 'This is your first note',
  //        'trashed': false,
  //        'pinned': false,
  //        'tags': ['Important'],
  //       'dateCreated': DateTime.now(),
  //       'dateModified': DateTime.now(),
  //     }
  //   ],
  // });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'date': 'Sort by date'},
      {'title': 'Sort by title'},
    ];
    return Scaffold(
      drawer: DrawerWidget(auth: _auth, title: 'Notes'),
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          //Search button
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search-note');
            },
            icon: const Icon(Icons.search),
          ),
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
        stream: FirebaseService().getNotesStream(),
        builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final notes = data.containsKey('user_notes')
                ? data['user_notes'] as List<dynamic>
                : [];

            final nonTrashedNotes =
                notes.where((note) => note['trashed'] == false).toList();
            final pinnedNotes = nonTrashedNotes
                .where((note) => note['pinned'] == true)
                .toList();
            final nonPinnedNotes = nonTrashedNotes
                .where((note) => note['pinned'] == false)
                .toList();

            if (nonPinnedNotes.isEmpty && pinnedNotes.isEmpty) {
              return const Center(
                child: Text('Add some notes'),
              );
            } else {
              if (sortOption == 'title') {
                nonPinnedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteA['title']
                      .toString()
                      .toLowerCase()
                      .compareTo(noteB['title'].toString().toLowerCase());
                });
                pinnedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteA['title']
                      .toString()
                      .toLowerCase()
                      .compareTo(noteB['title'].toString().toLowerCase());
                });
              } else if (sortOption == 'date') {
                nonPinnedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteB['dateModified'].compareTo(noteA['dateModified']);
                });
                pinnedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteB['dateModified'].compareTo(noteA['dateModified']);
                });
              }
              return ListView(
                children: [
                  if (pinnedNotes.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Pinned',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (pinnedNotes.isNotEmpty)
                    listView
                        ? NoteListView(
                            notes: pinnedNotes,
                            title: 'Home',
                          )
                        : NoteGridView(
                            notes: pinnedNotes,
                            title: 'Home',
                          ),
                  if (nonPinnedNotes.isNotEmpty && pinnedNotes.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Others',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (nonPinnedNotes.isNotEmpty)
                    listView
                        ? NoteListView(
                            notes: nonPinnedNotes,
                            title: 'Home',
                          )
                        : NoteGridView(
                            notes: nonPinnedNotes,
                            title: 'Home',
                          ),
                ],
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: StreamBuilder(
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
            if (_auth.currentUser!.emailVerified) {
              return FloatingActionButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  var result = await Navigator.pushNamed(context, '/add-note');
                  if (result != null) {
                    // show snackbar add note success
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Note added successfully'),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.add),
              );
            } else {
              if (notes.length < 5) {
                return FloatingActionButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    var result =
                        await Navigator.pushNamed(context, '/add-note');
                    if (result != null) {
                      // show snackbar add note success
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Note added successfully'),
                        ),
                      );
                    }
                  },
                  child: const Icon(Icons.add),
                );
              } else {
                return FloatingActionButton(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                            'You can only add 5 notes. Please verify your email to add more'),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                );
              }
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

