import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/note.dart';
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

  Future<dynamic> popAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('Changes on this note will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //check if title or content or tags are changed
        if (_titleController.text != widget.note.title ||
            _controller.document.toPlainText() != widget.note.content ||
            jsonEncode(_controller.document.toDelta().toJson()) !=
                widget.note.contentRich ||
            selectedTags != widget.note.tags) {
          var shouldPop = await popAlertDialog(context);
          return shouldPop ?? false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note Detail'),
          actions: [
            if (widget.title == 'Trash') ...[
              //restore note
              IconButton(
                onPressed: () async {
                  final note = Note(
                    id: widget.note.id,
                    title: widget.note.title,
                    trashed: false,
                    pinned: widget.note.pinned,
                    content: widget.note.content,
                    contentRich: widget.note.contentRich,
                    password: widget.note.password,
                    tags: widget.note.tags,
                    dateCreated: widget.note.dateCreated,
                    dateModified: DateTime.now(),
                  );
                  await _firebaseService.updateNote(
                      oldNote: widget.note, newNote: note);
                  Navigator.pop(context, 'restore');
                },
                icon: const Icon(Icons.restore),
              ),
              //delete permanently
              IconButton(
                onPressed: () async {
                  await _firebaseService.deleteNote(note: widget.note);
                  Navigator.pop(context, 'delete');
                },
                icon: const Icon(Icons.delete),
              ),
            ] else ...[
              IconButton(
                onPressed: () async {
                  //update the trashed to true
                  final note = Note(
                    id: widget.note.id,
                    title: widget.note.title,
                    trashed: true,
                    pinned: widget.note.pinned,
                    content: widget.note.content,
                    contentRich: widget.note.contentRich,
                    password: widget.note.password,
                    tags: widget.note.tags,
                    dateCreated: widget.note.dateCreated,
                    dateModified: DateTime.now(),
                  );
                  await _firebaseService.updateNote(
                      oldNote: widget.note, newNote: note);
                  Navigator.pop(context, 'delete');
                },
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () async {
                  final note = Note(
                    id: widget.note.id,
                    title: _titleController.text,
                    trashed: widget.note.trashed,
                    pinned: widget.note.pinned,
                    content: _controller.document.toPlainText(),
                    contentRich:
                        jsonEncode(_controller.document.toDelta().toJson()),
                    password: widget.note.password,
                    tags: selectedTags,
                    dateCreated: widget.note.dateCreated,
                    dateModified: DateTime.now(),
                  );
                  await _firebaseService.updateNote(
                      oldNote: widget.note, newNote: note);
                  Navigator.pop(context, 'update');
                },
                icon: const Icon(Icons.save),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "share",
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Share'),
                    ),
                  )
                ],
                onSelected: (value) {
                  if (value == 'share') {
                    Share.share(_controller.document.toPlainText(),
                        subject: _titleController.text);
                  }
                },
              )
            ],
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 13.0),
                child: TextField(
                  readOnly: widget.title == 'Trash' ? true : false,
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  minLines: 1,
                  maxLines: null,
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13.0),
                child: DropdownSearch<String>.multiSelection(
                  enabled: widget.title == 'Trash' ? false : true,
                  items: tags,
                  popupProps: const PopupPropsMultiSelection.menu(
                    showSelectedItems: true,
                  ),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Tags",
                      hintText: "Select Tags",
                      border: InputBorder.none,
                    ),
                  ),
                  onChanged: (List<String> value) {
                    selectedTags = value;
                  },
                  selectedItems: [...selectedTags],
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              Expanded(
                child: Column(
                  children: [
                    if (widget.title != 'Trash') ...[
                      QuillToolbar.basic(controller: _controller),
                      const Divider(
                        thickness: 2,
                      ),
                    ],
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
      ),
    );
  }
}
