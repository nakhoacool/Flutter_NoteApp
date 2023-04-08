import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import '/screens/Home/widgets/note_widget.dart';
import '/screens/home/detail_screen.dart';
import '../../models/note.dart';
import 'home_screen.dart';
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
  //       'dateCreated': DateTime.now(),
  //       'dateModified': DateTime.now(),
  //     }
  //   ],
  // });

  // get all notes that are trashed is true
  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'date': 'Sort by date'},
      {'title': 'Sort by title'},
    ];
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //use StreamBuilder to get user name, user email from user_profile
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('notes')
                            .doc(_auth.currentUser!.uid)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasData) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final profile =
                                data['user_profile'] as Map<String, dynamic>;
                            return Column(
                              children: [
                                Text(
                                  profile['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  profile['email'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Reminder'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Trash'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(
              thickness: 1,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('notes')
                  .doc(_auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final profile = data['user_profile'] as Map<String, dynamic>;
                  final tags = profile['tags'] as List<dynamic>;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index] as String;
                      return ListTile(
                        leading: const Icon(Icons.label),
                        title: Text(tag),
                        onTap: () {},
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const Divider(
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
                _auth.signOut();
              },
            ),
          ],
        ),
      ),
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
            final notes = data['user_notes'] as List<dynamic>;
            final nonTrashedNotes =
                notes.where((note) => note['trashed'] == true).toList();

            if (nonTrashedNotes.isEmpty) {
              return const Center(
                child: Text('There is no deleted notes'),
              );
            } else {
              if (sortOption == 'title') {
                nonTrashedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteA['title'].compareTo(noteB['title']);
                });
              } else if (sortOption == 'date') {
                nonTrashedNotes.sort((a, b) {
                  final noteA = a as Map<String, dynamic>;
                  final noteB = b as Map<String, dynamic>;
                  return noteB['dateModified'].compareTo(noteA['dateModified']);
                });
              }
              return listView
                  ? NoteListView(notes: nonTrashedNotes)
                  : NoteGridView(notes: nonTrashedNotes);
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
