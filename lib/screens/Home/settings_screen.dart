import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
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
    );
  }
}
