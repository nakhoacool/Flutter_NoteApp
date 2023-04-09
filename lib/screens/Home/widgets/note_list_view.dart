import 'package:flutter/material.dart';
import '../../../models/note.dart';
import '../detail_screen.dart';
import 'note_widget.dart';

class NoteListView extends StatelessWidget {
  const NoteListView({
    super.key,
    required this.notes,
    required this.title,
  });

  final List notes;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index] as Map<String, dynamic>;
        return GestureDetector(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            var result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(
                        note: Note.fromFirestore(note), title: title)));
            if (result != null) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Note $result successfully'),
                ),
              );
            }
          },
          child: NoteWidget(note: Note.fromFirestore(note)),
        );
      },
    );
  }
}
