import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/note.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late TextEditingController _tagController;


  @override
  void initState() {
    _tagController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    backgroundImage: CachedNetworkImageProvider(
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
                                Text(
                                  'Status: ${_auth.currentUser!.emailVerified ? 'Verified' : 'Not Verified'}',
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
                Navigator.pushReplacementNamed(context, '/trash');
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
                    physics: const ClampingScrollPhysics(),
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
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
                _auth.signOut();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(context, '/change_password');
            },
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              'Notes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Change Theme'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Change Font'),
            onTap: () {},
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              'Reminder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Reminder'),
            onTap: () {},
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              'Tags',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Tag'),
            onTap: () {
              // show add tag dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Add Tag'),
                    content: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Enter tag name',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // add tag to database
                          FirebaseFirestore.instance
                              .collection('notes')
                              .doc(_auth.currentUser!.uid)
                              .update({
                            'user_profile.tags': FieldValue.arrayUnion(
                              [_tagController.text],
                            ),
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('notes')
                .doc(_auth.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                final tags = snapshot.data!['user_profile']['tags'];
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index] as String;
                    return ListTile(
                      leading: const Icon(Icons.label),
                      title: Text(tag),
                      onTap: () {
                        // show rename or delete tag dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Rename or Delete Tag'),
                              content: TextField(
                                controller: _tagController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter tag name',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // delete tag
                                    FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(_auth.currentUser!.uid)
                                        .update({
                                      'user_profile.tags':
                                          FieldValue.arrayRemove(
                                        [tag],
                                      ),
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // rename tag
                                    final newTag = _tagController.text;
                                    await FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(_auth.currentUser!.uid)
                                        .update({
                                      'user_profile.tags':
                                          FieldValue.arrayRemove([tag]),
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(_auth.currentUser!.uid)
                                        .update({
                                      'user_profile.tags':
                                          FieldValue.arrayUnion([newTag]),
                                    });

                                    // update tag in notes
                                    final notesRef = FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(_auth.currentUser!.uid);
                                    final notes = await notesRef.get();
                                    for (var note in notes['user_notes']) {
                                      final tagNote =
                                          List<String>.from(note['tags'] ?? []);
                                      if (tagNote.contains(tag)) {
                                        tagNote.remove(tag);
                                        tagNote.add(newTag);
                                        await notesRef.update({
                                          'user_notes':
                                              FieldValue.arrayRemove([note]),
                                        });
                                        await notesRef.update({
                                          'user_notes': FieldValue.arrayUnion([
                                            {
                                              'id': note['id'],
                                              'title': note['title'],
                                              'content': note['content'],
                                              'contentRich':
                                                  note['contentRich'],
                                              'trashed': note['trashed'],
                                              'pinned': note['pinned'],
                                              'tags': tagNote,
                                              'dateCreated':
                                                  note['dateCreated'],
                                              'dateModified':
                                                  note['dateModified'],
                                            }
                                          ]),
                                        });
                                      }
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Rename'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),

          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // show about dialog
              showAboutDialog(
                context: context,
                applicationName: 'Notes',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.note),
                applicationLegalese: '© 2023 Notes',
                children: [
                  const Text(
                    'Create by:\nNguyen Anh Khoa\nPham Nguyen Phat Dat\nNguyen Ngoc Bao Uyen',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
