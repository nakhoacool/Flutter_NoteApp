import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../constants.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    _titleController = TextEditingController();
    _contentController = TextEditingController();
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
        title: const Text('Add Note'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: kPrimaryColor),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
          ),
          TextFormField(
            controller: _contentController,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              labelText: 'Content',
              labelStyle: TextStyle(color: kPrimaryColor),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isEmpty &&
                  _contentController.text.isEmpty) {
                Navigator.pop(context);
              } else {
                FirebaseFirestore.instance
                    .collection('notes')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  'user_notes': FieldValue.arrayUnion([
                    {
                      'id': const Uuid().v4(),
                      'title': _titleController.text,
                      'content': _contentController.text,
                      'trashed': false,
                      'dateCreated': DateTime.now(),
                      'dateModified': DateTime.now(),
                    }
                  ]),
                });
                Navigator.pop(context, true);
              }
            },
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }
}
