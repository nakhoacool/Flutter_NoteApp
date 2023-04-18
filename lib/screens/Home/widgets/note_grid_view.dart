import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../models/note.dart';
import '../../../services/firebase_service.dart';
import '../detail_screen.dart';
import 'note_widget.dart';

class NoteGridView extends StatelessWidget {
  const NoteGridView({
    super.key,
    required this.notes,
    required this.title,
  });

  final List notes;
  final String title;

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();
    final messenger = ScaffoldMessenger.of(context);
    return MasonryGridView.count(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        scrollDirection: Axis.vertical,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index] as Map<String, dynamic>;
          return GestureDetector(
            onTap: () async {
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
            onLongPress: title == 'Home'
                ? () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // show pin/unpin
                            ListTile(
                              leading: const Icon(Icons.push_pin),
                              title: Text(note['pinned'] ? 'Unpin' : 'Pin'),
                              onTap: () async {
                                // update the note to pin or unpin
                                Navigator.pop(context);
                                await _firebaseService.togglePinNote(note);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Note ${note['pinned'] ? 'unpinned' : 'pinned'} successfully'),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                : null,
            child: NoteWidget(note: Note.fromFirestore(note)),
          );
        });
  }
}
