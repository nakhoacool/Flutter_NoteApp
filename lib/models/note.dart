import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String id;
  String title;
  String content;
  DateTime dateCreated;
  DateTime dateModified;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateCreated,
    required this.dateModified,
  });

  //get data from firestore
  Note.fromFirestore(Map<String, dynamic> firestore)
      : id = firestore['id'],
        title = firestore['title'],
        content = firestore['content'],
        dateCreated = (firestore['dateCreated'] as Timestamp).toDate(),
        dateModified = (firestore['dateModified'] as Timestamp).toDate();
        
  //convert to firestore

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
    };
  }
}
