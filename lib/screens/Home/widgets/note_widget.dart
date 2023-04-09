import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';

class NoteWidget extends StatefulWidget {
  final Note note;
  const NoteWidget({super.key, required this.note});

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          //color: colors[widget.note.color],
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
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
            if (widget.note.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                child: Text(
                  widget.note.content,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.note.dateModified.toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            //   if (widget.note.reminder != null)
            //     if (DateTime.parse(widget.note.reminder).isBefore(DateTime.now()))
            //       Container(
            //         decoration: BoxDecoration(
            //           border: Border(
            //             top: BorderSide(
            //               color: Colors.black,
            //               width: 1,
            //             ),
            //           ),
            //         ),
            //         child: Row(
            //           // crossAxisAlignment: CrossAxisAlignment.start,
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             InkWell(
            //               onTap: () {
            //                 print('object');
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text(
            //                   'Mark As Done',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.black,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             Theme(
            //               data: Theme.of(context).copyWith(
            //                 unselectedWidgetColor: Colors.black,
            //               ),
            //               child: Checkbox(
            //                 onChanged: (value) async {
            //                   widget.note.markAsDone = value.toString();
            //                   await dbHelper.updateNote(widget.note);
            //                   setState(() {});
            //                 },
            //                 value: _markAsDone,
            //                 activeColor: Colors.black,
            //                 hoverColor: Colors.black,
            //                 visualDensity: VisualDensity(vertical: 2.0),
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
          ],
        ),
      ),
    );
  }
}
