import 'package:flutter/material.dart';
import '../../../models/note.dart';
import '../detail_screen.dart';
import 'note_widget.dart';


class NoteListView extends StatelessWidget {
  const NoteListView({
    super.key,
    required this.notes,
  });

  final List notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index] as Map<String, dynamic>;
        return GestureDetector(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            var result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NoteDetailScreen(note: Note.fromFirestore(note))));
            if (result != null) {
              if (result == 'update') {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Note updated successfully'),
                  ),
                );
              }
              if (result == 'delete') {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Note deleted successfully'),
                  ),
                );
              }
            }
          },
          child: NoteWidget(note: Note.fromFirestore(note)),
        );
      },
    );
  }
}
