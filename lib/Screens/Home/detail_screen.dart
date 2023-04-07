import 'dart:convert';

import 'package:flutter/material.dart';
import '../../models/note.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late QuillController _controller;
  late TextEditingController _titleController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.note.title);
    _controller = QuillController(
      document: Document.fromJson(jsonDecode(widget.note.contentRich)),
      selection: const TextSelection.collapsed(offset: 0),
    );
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
        title: const Text('Note Detail'),
        actions: [
          IconButton(
            onPressed: () {
              final note = Note(
                id: widget.note.id,
                title: _titleController.text,
                trashed: widget.note.trashed,
                content: _controller.document.toPlainText(),
                contentRich:
                    jsonEncode(_controller.document.toDelta().toJson()),
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
                content: _controller.document.toPlainText(),
                contentRich:
                    jsonEncode(_controller.document.toDelta().toJson()),
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
            Expanded(
              child: Column(
                children: [
                  QuillToolbar.basic(controller: _controller),
                  const SizedBox(height: 16),
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
