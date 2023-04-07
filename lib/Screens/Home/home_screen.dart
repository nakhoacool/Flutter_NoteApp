import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import '/screens/Home/widgets/note_widget.dart';
import '/screens/home/detail_screen.dart';
import '../../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  bool listView = true;
  String sortOption = 'title';
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
  //       'dateCreated': DateTime.now(),
  //       'dateModified': DateTime.now(),
  //     }
  //   ],
  // });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'title': 'Sort by title'},
      {'date': 'Sort by date'},
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
                title: const Text('Notes'),
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return const HomeScreen();
                    },
                  ));
                },
              ),
              ListTile(
                title: const Text('Reminder'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Trash'),
                onTap: () {},
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
                    final profile =
                        data['user_profile'] as Map<String, dynamic>;
                    final tags = profile['tags'] as List<dynamic>;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index] as String;
                        return ListTile(
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
                title: const Text('Settings'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Sign Out'),
                onTap: () {
                  _auth.signOut();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            //Search button
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/search-note');
                },
                icon: const Icon(Icons.search)),
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

              if (notes.isEmpty) {
                return const Center(
                  child: Text('Add some notes'),
                );
              } else {
                if (sortOption == 'title') {
                  notes.sort((a, b) {
                    final noteA = a as Map<String, dynamic>;
                    final noteB = b as Map<String, dynamic>;
                    return noteA['title'].compareTo(noteB['title']);
                  });
                } else if (sortOption == 'date') {
                  notes.sort((a, b) {
                    final noteA = a as Map<String, dynamic>;
                    final noteB = b as Map<String, dynamic>;
                    return noteA['dateModified']
                        .compareTo(noteB['dateModified']);
                  });
                }
                return listView
                    ? NoteListView(notes: notes)
                    : NoteGridView(notes: notes);
              }
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
