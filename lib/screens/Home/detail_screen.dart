import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/note.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import '../../services/firebase_service.dart';
import '../../utils/notification_helper.dart';

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
  NotificationHelper notificationHelper = NotificationHelper();

  List<String> tags = <String>[];
  List selectedTags = <String>[];
  String _pickedDate = '';
  String _pickedTime = '';

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

    if (widget.note.reminder != '') {
      _pickedDate =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.note.reminder));
      _pickedTime =
          DateFormat('kk:mm').format(DateTime.parse(widget.note.reminder));
    } else {
      _pickedDate = '';
      _pickedTime = '';
    }
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
                    reminder: widget.note.reminder,
                    dateCreated: widget.note.dateCreated,
                    dateModified: DateTime.now(),
                  );
                  await _firebaseService.updateNote(
                      oldNote: widget.note, newNote: note);
                  Navigator.pop(context, 'restored');
                },
                icon: const Icon(Icons.restore),
              ),
              //delete permanently
              IconButton(
                onPressed: () async {
                  await _firebaseService.deleteNote(note: widget.note);
                  Navigator.pop(context, 'deleted permanently');
                },
                icon: const Icon(Icons.delete),
              ),
            ] else ...[
              //show a date time picker
              IconButton(
                onPressed: () async {
                  var result = await _showAddReminderDialog();
                  if (result != null) {
                    if (result == 'delete') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder deleted'),
                        ),
                      );
                    }
                    if (result == 'save') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder added'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add_alarm),
              ),
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
                    reminder: widget.note.reminder,
                    dateCreated: widget.note.dateCreated,
                    dateModified: DateTime.now(),
                  );
                  await _firebaseService.updateNote(
                      oldNote: widget.note, newNote: note);
                  await notificationHelper
                      .deleteNotification(int.parse(widget.note.id));
                  Navigator.pop(context, 'deleted');
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
                    reminder: _pickedDate == '' || _pickedTime == ''
                        ? ''
                        : _pickedDate + ' ' + _pickedTime,
                    dateCreated: widget.note.dateCreated,
                    dateModified: DateTime.now(),
                  );
                  await _firebaseService.updateNote(
                      oldNote: widget.note, newNote: note);
                  if (_pickedDate != '' && _pickedTime != '') {
                    notificationHelper.scheduledNotification(
                        _pickedDate,
                        _pickedTime,
                        int.parse(widget.note.id),
                        widget.note.title,
                        widget.note.content);
                  }
                  Navigator.pop(context, 'updated');
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

  _showAddReminderDialog() async {
    String res = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        //Return the Alert Dialog
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Reminder'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          //Alert Dialog Container
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Date Picker Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_pickedDate),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: const Text('Pick Date'),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: widget.note.reminder != ''
                              ? DateTime.parse(widget.note.reminder)
                              : DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ).then(
                          (value) {
                            if (value != null) {
                              setState(() {
                                _pickedDate = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(value.toString()));
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              //Time Picker Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_pickedTime),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: const Text('Pick Time'),
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: widget.note.reminder != ''
                              ? TimeOfDay(
                                  hour: int.parse(widget.note.reminder
                                      .substring(11, 16)
                                      .split(':')[0]),
                                  minute: int.parse(widget.note.reminder
                                      .substring(11, 16)
                                      .split(':')[1]),
                                )
                              : TimeOfDay.now(),
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              _pickedTime = DateFormat('kk:mm').format(
                                  DateTime(0, 0, 0, value.hour, value.minute));
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
          actions: [
            if (widget.note.reminder != '')
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  _deleteReminder(context);
                  Navigator.of(context).pop('delete');
                },
              ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop('save');
              },
            ),
          ],
          actionsPadding: const EdgeInsets.all(8),
        ),
      ),
    );
    return res;
  }

  _deleteReminder(BuildContext context) async {
    await notificationHelper.deleteNotification(int.parse(widget.note.id));
    setState(() {
      _pickedDate = '';
      _pickedTime = '';
    });
  }
}
