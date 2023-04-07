import 'package:flutter/material.dart';
import '../../models/note.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Detail'),
        actions: [
          IconButton(
            onPressed: () {
              final note = Note(
                id: widget.note.id,
                title: _titleController.text,
                trashed: widget.note.trashed,
                content: _contentController.text,
                dateCreated: widget.note.dateCreated,
                dateModified: DateTime.now(),
              );
              FirebaseFirestore.instance
                  .collection('notes')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'user_notes':
                    FieldValue.arrayRemove([widget.note.toFirestore()]),
              });
              FirebaseFirestore.instance
                  .collection('notes')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'user_notes': FieldValue.arrayUnion([note.toFirestore()]),
              });
              Navigator.pop(context, 'update');
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              // FirebaseFirestore.instance
              //     .collection('notes')
              //     .doc(FirebaseAuth.instance.currentUser!.uid)
              //     .update({
              //   'user_notes':
              //       FieldValue.arrayRemove([widget.note.toFirestore()]),
              // });
              //update the trashed to true
              final note = Note(
                id: widget.note.id,
                title: _titleController.text,
                trashed: true,
                content: _contentController.text,
                dateCreated: widget.note.dateCreated,
                dateModified: DateTime.now(),
              );
              FirebaseFirestore.instance
                  .collection('notes')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'user_notes':
                    FieldValue.arrayRemove([widget.note.toFirestore()]),
              });
              FirebaseFirestore.instance
                  .collection('notes')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'user_notes': FieldValue.arrayUnion([note.toFirestore()]),
              });
              Navigator.pop(context, 'delete');
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              minLines: 10,
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
