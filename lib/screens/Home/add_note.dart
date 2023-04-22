import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:intl/intl.dart';

import '../../services/firebase_service.dart';
import '../../utils/notification_helper.dart';
import '../../utils/number_generate.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final QuillController _controller = QuillController.basic();
  late TextEditingController _titleController;
  final FirebaseService _firebaseService = FirebaseService();
  NotificationHelper notificationHelper = NotificationHelper();
  String uuid = generateNumericUuid();
  String _pickedDate = '';
  String _pickedTime = '';

  List<String> tags = <String>[];
  List<String> selectedTags = <String>[];

  @override
  void initState() {
    _titleController = TextEditingController();
    _firebaseService.getTags().then((value) {
      setState(() {
        tags = value;
      });
    });
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
            onPressed: () {
              if (_titleController.text.isEmpty &&
                  _controller.document.isEmpty()) {
                Navigator.pop(context);
              } else {
                _firebaseService.addNote(
                  uuid: uuid,
                  title: _titleController.text,
                  controller: _controller,
                  selectedTags: selectedTags,
                  reminder: _pickedDate == '' || _pickedTime == ''
                      ? ''
                      : _pickedDate + ' ' + _pickedTime,
                );
                if (_pickedDate != '' && _pickedTime != '') {
                  notificationHelper.scheduledNotification(
                    _pickedDate,
                    _pickedTime,
                    int.parse(uuid),
                    _titleController.text,
                    _controller.document.toPlainText(),
                  );
                }
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
            Padding(
              padding: const EdgeInsets.only(left: 13.0),
              child: TextField(
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
              ),
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

  _showAddReminderDialog() async {
    String res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
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
                          initialDate: DateTime.now(),
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
                          initialTime: TimeOfDay.now(),
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
            if (_pickedDate != '' && _pickedTime != '')
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
    await notificationHelper.deleteNotification(int.parse(uuid));
    setState(() {
      _pickedDate = '';
      _pickedTime = '';
    });
  }
}
