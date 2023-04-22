import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:intl/intl.dart';

class NoteWidget extends StatefulWidget {
  final Note note;
  const NoteWidget({super.key, required this.note});

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  bool _reminderShown = false;

  @override
  void initState() {
    super.initState();
    _updateReminderShown();
  }

  @override
  void didUpdateWidget(NoteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note != widget.note) {
      _reminderShown = false;
      _updateReminderShown();
    }
  }

  void _updateReminderShown() {
    if (widget.note.reminder.isNotEmpty && widget.note.trashed == false) {
      final reminderTime = DateTime.parse(widget.note.reminder);
      if (DateTime.now().isBefore(reminderTime)) {
        // The reminder time is in the future, so set _reminderShown to true
        _reminderShown = true;

        // Schedule a callback to update the state when the reminder time is reached
        Future.delayed(reminderTime.difference(DateTime.now()), () {
          if (mounted) {
            setState(() {
              _reminderShown = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.yellow.shade300,
            borderRadius: const BorderRadius.all(
              Radius.circular(15.0),
            ),
            border: Border.all(width: 2.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.note.title.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Text(
                    widget.note.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Divider(
                color: Colors.black,
                thickness: 1,
              ),
              if (widget.note.content.isNotEmpty &&
                  widget.note.password.isEmpty) ...[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Text(
                    widget.note.content,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ] else ...[
                if (widget.note.content.isNotEmpty &&
                    widget.note.password.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                      'This note is password protected',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_reminderShown)
                    const Icon(
                      Icons.notifications,
                      color: Colors.red,
                    ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat('dd-MM-yyyy – kk:mm')
                          .format(widget.note.dateModified),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      if (widget.note.password.isNotEmpty)
        const Positioned(
          right: 0,
          top: 0,
          child: Icon(
            Icons.lock,
            color: Colors.red,
          ),
        )
    ]);
  }
}
