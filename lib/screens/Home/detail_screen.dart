import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/note.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import '../../services/firebase_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final String title;
  const NoteDetailScreen({Key? key, required this.note, required this.title})
      : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late QuillController _controller;
  late TextEditingController _titleController;
  final FirebaseService _firebaseService = FirebaseService();

  List<String> tags = <String>[];
  List selectedTags = <String>[];

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.note.title);
    _controller = QuillController(
      document: Document.fromJson(jsonDecode(widget.note.contentRich)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _firebaseService.getTags().then((value) {
      setState(() {
        tags = value;
      });
    });

    selectedTags = widget.note.tags;
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
          if (widget.title == 'Trash') ...[
            //restore note
            IconButton(
              onPressed: () {
                final note = Note(
                  id: widget.note.id,
                  title: _titleController.text,
                  trashed: false,
                  pinned: widget.note.pinned,
                  content: _controller.document.toPlainText(),
                  contentRich:
                      jsonEncode(_controller.document.toDelta().toJson()),
                  tags: widget.note.tags,
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
                Navigator.pop(context, 'restore');
              },
              icon: const Icon(Icons.restore),
            ),
            //delete permanently
            IconButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('notes')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  'user_notes':
                      FieldValue.arrayRemove([widget.note.toFirestore()]),
                });
                Navigator.pop(context, 'delete');
              },
              icon: const Icon(Icons.delete),
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                final note = Note(
                  id: widget.note.id,
                  title: _titleController.text,
                  trashed: widget.note.trashed,
                  pinned: widget.note.pinned,
                  content: _controller.document.toPlainText(),
                  contentRich:
                      jsonEncode(_controller.document.toDelta().toJson()),
                  tags: selectedTags,
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
                //update the trashed to true
                final note = Note(
                  id: widget.note.id,
                  title: _titleController.text,
                  trashed: true,
                  pinned: widget.note.pinned,
                  content: _controller.document.toPlainText(),
                  contentRich:
                      jsonEncode(_controller.document.toDelta().toJson()),
                  tags: widget.note.tags,
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              readOnly: widget.title == 'Trash' ? true : false,
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Title',
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: null,
            ),
            const Divider(
              thickness: 2,
            ),
            DropdownSearch<String>.multiSelection(
              items: tags,
              popupProps: const PopupPropsMultiSelection.menu(
                showSelectedItems: true,
              ),
              onChanged: (List<String> value) {
                selectedTags = value;
              },
              selectedItems: [...selectedTags],
            ),
            const Divider(
              thickness: 2,
            ),
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
                    readOnly: widget.title == 'Trash' ? true : false,
                    showCursor: widget.title == 'Trash' ? false : true,
                    expands: false,
                    padding: const EdgeInsets.all(16),
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
