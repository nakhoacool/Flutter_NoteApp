import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../services/firebase_service.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
    required FirebaseAuth auth,
    required this.title,
  }) : _auth = auth;

  final FirebaseAuth _auth;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                      stream: FirebaseService().getNotesStream(),
                      builder: (
                        context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot,
                      ) {
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
                        return const Center(child: CircularProgressIndicator());
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
              if (title != 'Notes') {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Trash'),
            onTap: () {
              if (title != 'Trash') {
                Navigator.pushReplacementNamed(context, '/trash');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          StreamBuilder(
            stream: FirebaseService().getNotesStream(),
            builder: (
              context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.hasData) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final profile = data['user_profile'] as Map<String, dynamic>;
                final tags = profile['tags'] as List<dynamic>;
                tags.sort();
                return tags.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          const Divider(
                            thickness: 1,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: tags.length,
                            itemBuilder: (context, index) {
                              final tag = tags[index] as String;
                              return ListTile(
                                leading: const Icon(Icons.label),
                                title: Text(tag),
                                onTap: () {
                                  Navigator.pushNamed(context, '/tags/$tag');
                                },
                              );
                            },
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                        ],
                      );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              if (title != 'Settings') {
                Navigator.pushReplacementNamed(context, '/settings');
              } else {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }
}
