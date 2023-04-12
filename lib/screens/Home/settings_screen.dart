import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Otp/email.dart';
import 'widgets/note_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _tagFormKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
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
      drawer: DrawerWidget(auth: _auth, title: 'Settings'),
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
              _auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
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
            title: const Text('Verify Email'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const EmailScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              //TODO: add change password screen
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
                    content: Form(
                      key: _tagFormKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter tag name';
                          }
                          return null;
                        },
                        controller: _tagController,
                        decoration: const InputDecoration(
                          hintText: 'Enter tag name',
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _tagController.clear();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // add tag to database
                          if (_tagFormKey.currentState!.validate()) {
                            final tag = _tagController.text;
                            FirebaseFirestore.instance
                                .collection('notes')
                                .doc(_auth.currentUser!.uid)
                                .update({
                              'user_profile.tags': FieldValue.arrayUnion(
                                [tag],
                              ),
                            });
                            Navigator.pop(context);
                            _tagController.clear();
                          }
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
                //sort tags alphabetically
                tags.sort();
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
                        _tagController.text = tag;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Rename or Delete Tag'),
                              content: Form(
                                key: _tagFormKey,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter tag name';
                                    }
                                    return null;
                                  },
                                  controller: _tagController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter tag name',
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    // delete tag
                                    await FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(_auth.currentUser!.uid)
                                        .update({
                                      'user_profile.tags':
                                          FieldValue.arrayRemove(
                                        [tag],
                                      ),
                                    });

                                    // delete the corespoinding tag from notes
                                    final notesRef = FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(_auth.currentUser!.uid);
                                    final notes = await notesRef.get();
                                    for (var note in notes['user_notes']) {
                                      final tagNote =
                                          List<String>.from(note['tags'] ?? []);
                                      if (tagNote.contains(tag)) {
                                        tagNote.remove(tag);
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
                                    _tagController.clear();
                                  },
                                  child: const Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // rename tag
                                    if (_tagFormKey.currentState!.validate()) {
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
                                      final notesRef = FirebaseFirestore
                                          .instance
                                          .collection('notes')
                                          .doc(_auth.currentUser!.uid);
                                      final notes = await notesRef.get();
                                      for (var note in notes['user_notes']) {
                                        final tagNote = List<String>.from(
                                            note['tags'] ?? []);
                                        if (tagNote.contains(tag)) {
                                          tagNote.remove(tag);
                                          tagNote.add(newTag);
                                          await notesRef.update({
                                            'user_notes':
                                                FieldValue.arrayRemove([note]),
                                          });
                                          await notesRef.update({
                                            'user_notes':
                                                FieldValue.arrayUnion([
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
                                      _tagController.clear();
                                    }
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
