import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String id;
  String title;
  String content;
  String contentRich;
  bool trashed;
  bool pinned;
  DateTime dateCreated;
  DateTime dateModified;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.contentRich,
    required this.trashed,
    required this.pinned,
    required this.dateCreated,
    required this.dateModified,
  });

  //get data from firestore
  Note.fromFirestore(Map<String, dynamic> firestore)
      : id = firestore['id'],
        title = firestore['title'],
        content = firestore['content'],
        contentRich = firestore['contentRich'],
        trashed = firestore['trashed'],
        pinned = firestore['pinned'],
        dateCreated = (firestore['dateCreated'] as Timestamp).toDate(),
        dateModified = (firestore['dateModified'] as Timestamp).toDate();

  //convert to firestore

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentRich': contentRich,
      'trashed': trashed,
      'pinned': pinned,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
    };
  }
}
