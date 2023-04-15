import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';
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
            onPressed: () async {
              await FirebaseService().signOut();
              Navigator.pushReplacementNamed(context, '/');
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
                barrierDismissible: false,
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
                        onPressed: () async {
                          // add tag to database
                          if (_tagFormKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            final tag = _tagController.text;
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                            await FirebaseService().createTag(tag);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tag $tag added'),
                              ),
                            );
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
                      //trailling popup menu
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          if (value == 'rename') {
                            _tagController.text = tag;
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Rename Tag'),
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
                                      onPressed: () async {
                                        // rename tag
                                        if (_tagFormKey.currentState!
                                            .validate()) {
                                          final newTag = _tagController.text;
                                          FocusScope.of(context).unfocus();
                                          //show loading dialog
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                          );
                                          await FirebaseService()
                                              .renameTag(tag, newTag);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Tag renamed successfully'),
                                            ),
                                          );
                                          _tagController.clear();
                                        }
                                      },
                                      child: const Text('Rename'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          if (value == 'delete') {
                            _tagController.text = tag;
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Tag'),
                                  content: RichText(
                                    text: TextSpan(
                                      text: 'Are you sure you want to delete ',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: tag,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: '?',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
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
                                      onPressed: () async {
                                        // delete tag
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                        );
                                        await FirebaseService().deleteTag(tag);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Tag deleted successfully'),
                                          ),
                                        );
                                        _tagController.clear();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
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
