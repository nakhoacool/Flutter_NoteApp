import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../constants.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final QuillController _controller = QuillController.basic();
  late TextEditingController _titleController;

  @override
  void initState() {
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        actions: [
          IconButton(
            onPressed: () {
              if (_titleController.text.isEmpty &&
                  _controller.document.isEmpty()) {
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
                      'content': _controller.document.toPlainText(),
                      'contentRich':
                          jsonEncode(_controller.document.toDelta().toJson()),
                      'trashed': false,
                      'dateCreated': DateTime.now(),
                      'dateModified': DateTime.now(),
                    }
                  ]),
                });
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(
              thickness: 2,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  QuillToolbar.basic(controller: _controller),
                  const Divider(
                    thickness: 2,
                  ),
                  QuillEditor(
                    controller: _controller,
                    scrollController: ScrollController(),
                    scrollable: true,
                    autoFocus: false,
                    focusNode: FocusNode(),
                    readOnly: false,
                    expands: false,
                    padding: const EdgeInsets.all(8),
                    placeholder: 'Write something...',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
