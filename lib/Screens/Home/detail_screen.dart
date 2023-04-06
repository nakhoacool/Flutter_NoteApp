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
  final _formKey = GlobalKey<FormState>();
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
              _formKey.currentState!.save();
              final note = Note(
                id: widget.note.id,
                title: _titleController.text,
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
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('notes')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'user_notes':
                    FieldValue.arrayRemove([widget.note.toFirestore()]),
              });
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
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
                maxLines: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
