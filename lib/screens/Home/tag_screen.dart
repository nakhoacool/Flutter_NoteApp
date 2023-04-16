import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/note_grid_view.dart';

class TagScreen extends StatefulWidget {
  final String tagId;
  const TagScreen({super.key, required this.tagId});

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tagId),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final notes = data['user_notes'] as List<dynamic>;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index] as Map<String, dynamic>;
                final tags = note['tags'] as List<dynamic>;
                if (tags.contains(widget.tagId)) {
                  return NoteGridView(
                    notes: [note],
                    title: widget.tagId,
                  );
                }
                return const SizedBox.shrink();
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
