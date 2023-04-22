import 'package:cloud_firestore/cloud_firestore.dart';

//! THEM THUOC TINH O DAY THI QUA FIREBASE_SERVICE CAP NHAT LAI
class Note {
  String id;
  String title;
  String content;
  String contentRich;
  String password;
  List tags;
  bool trashed;
  bool pinned;
  String reminder;
  DateTime dateCreated;
  DateTime dateModified;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.contentRich,
    required this.password,
    required this.tags,
    required this.trashed,
    required this.pinned,
    required this.reminder,
    required this.dateCreated,
    required this.dateModified,
  });

  //get data from firestore
  Note.fromFirestore(Map<String, dynamic> firestore)
      : id = firestore['id'],
        title = firestore['title'],
        content = firestore['content'],
        contentRich = firestore['contentRich'],
        password = firestore['password'],
        tags = firestore['tags'],
        trashed = firestore['trashed'],
        pinned = firestore['pinned'],
        reminder = firestore['reminder'],
        dateCreated = (firestore['dateCreated'] as Timestamp).toDate(),
        dateModified = (firestore['dateModified'] as Timestamp).toDate();

  //convert to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentRich': contentRich,
      'password': password,
      'tags': tags,
      'trashed': trashed,
      'pinned': pinned,
      'reminder': reminder,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
    };
  }
}
