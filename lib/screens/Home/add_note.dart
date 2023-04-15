import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final QuillController _controller = QuillController.basic();
  late TextEditingController _titleController;

  final List<String> tags = <String>[];
  List selectedTags = <String>[];

  // get tags from firestore
  Future<void> getTags() async {
    final tagsSnapshot = await FirebaseFirestore.instance
        .collection('notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final tagsData = tagsSnapshot.data() as Map<String, dynamic>;
    final tagsList = tagsData['user_profile']['tags'] as List<dynamic>;
    for (final tag in tagsList) {
      tags.add(tag as String);
    }
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    getTags();
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
                      'tags': selectedTags,
                      'trashed': false,
                      'pinned': false,
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
            TextField(
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
                    readOnly: false,
                    expands: false,
                    padding: const EdgeInsets.all(18),
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
