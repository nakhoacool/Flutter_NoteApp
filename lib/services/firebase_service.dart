import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../models/note.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //root stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getNotesStream() {
    return _firestore
        .collection('notes')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  //sign up
  Future<String?> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      await _firestore.collection('notes').doc(userCredential.user!.uid).set({
        'user_profile': {
          'email': userCredential.user!.email,
          'name': name,
          'tags': [
            'Work',
            'Personal',
          ],
        },
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //sign in
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    }
  }

  //change password
  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {
    try {
      var cred = EmailAuthProvider.credential(
          email: _auth.currentUser!.email.toString(), password: oldPassword);
      await _auth.currentUser!.reauthenticateWithCredential(cred);
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    } catch (e) {
      throw e;
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //get notes
  Future<List<Note>> getNotes() async {
    final notesSnapshot =
        await _firestore.collection('notes').doc(_auth.currentUser!.uid).get();
    final notesData = notesSnapshot.data()!['user_notes'] as List;
    final notes = notesData.map((e) => Note.fromFirestore(e)).toList();
    return notes.where((note) => !note.trashed && note.password == "").toList();
  }

  //get tags from firestore
  Future<List<String>> getTags() async {
    final tagsSnapshot =
        await _firestore.collection('notes').doc(_auth.currentUser!.uid).get();
    final tagsData = tagsSnapshot.data() as Map<String, dynamic>;
    final tagsList = tagsData['user_profile']['tags'] as List<dynamic>;
    return tagsList.cast<String>();
  }

  //get note by id
  Future<Map<String, dynamic>> getNoteById(String id) async {
    final notesSnapshot =
        await _firestore.collection('notes').doc(_auth.currentUser!.uid).get();
    final notesData = notesSnapshot.data() as Map<String, dynamic>;
    final notesList = notesData['user_notes'] as List<dynamic>;
    final note = notesList.firstWhere((element) => element['id'] == id);
    return note;
  }

  Future<void> togglePinNote(Map<String, dynamic> note) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayRemove([
        {
          'id': note['id'],
          'title': note['title'],
          'content': note['content'],
          'contentRich': note['contentRich'],
          'password': note['password'],
          'trashed': note['trashed'],
          'pinned': note['pinned'],
          'tags': note['tags'],
          'reminder': note['reminder'],
          'dateCreated': note['dateCreated'],
          'dateModified': note['dateModified'],
        }
      ]),
    });
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayUnion([
        {
          'id': note['id'],
          'title': note['title'],
          'content': note['content'],
          'contentRich': note['contentRich'],
          'password': note['password'],
          'trashed': note['trashed'],
          'pinned': !note['pinned'],
          'tags': note['tags'],
          'reminder': note['reminder'],
          'dateCreated': note['dateCreated'],
          'dateModified': note['dateModified'],
        }
      ]),
    });
  }

  Future<void> protectNote(Map<String, dynamic> note, String password) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayRemove([
        {
          'id': note['id'],
          'title': note['title'],
          'content': note['content'],
          'contentRich': note['contentRich'],
          'password': note['password'],
          'trashed': note['trashed'],
          'pinned': note['pinned'],
          'tags': note['tags'],
          'reminder': note['reminder'],
          'dateCreated': note['dateCreated'],
          'dateModified': note['dateModified'],
        }
      ]),
    });
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayUnion([
        {
          'id': note['id'],
          'title': note['title'],
          'content': note['content'],
          'contentRich': note['contentRich'],
          'password': password,
          'trashed': note['trashed'],
          'pinned': note['pinned'],
          'tags': note['tags'],
          'reminder': note['reminder'],
          'dateCreated': note['dateCreated'],
          'dateModified': note['dateModified'],
        }
      ]),
    });
  }

  //add note
  Future<void> addNote({
    required String uuid,
    required String title,
    required QuillController controller,
    required List<String> selectedTags,
    required String reminder,
  }) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayUnion([
        {
          'id': uuid,
          'title': title,
          'content': controller.document.toPlainText(),
          'contentRich': jsonEncode(controller.document.toDelta().toJson()),
          'password': '',
          'tags': selectedTags,
          'trashed': false,
          'pinned': false,
          'reminder': reminder,
          'dateCreated': DateTime.now(),
          'dateModified': DateTime.now(),
        }
      ]),
    });
  }

  Future<void> updateNote(
      {required Note oldNote, required Note newNote}) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayRemove([oldNote.toFirestore()]),
    });
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayUnion([newNote.toFirestore()]),
    });
  }

  Future<void> deleteNote({
    required Note note,
  }) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayRemove([note.toFirestore()]),
    });
  }

  //create tag
  Future<void> createTag(String tag) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_profile.tags': FieldValue.arrayUnion(
        [tag],
      ),
    });
  }

  //delete tag
  Future<void> deleteTag(String tag) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_profile.tags': FieldValue.arrayRemove(
        [tag],
      ),
    });
    // delete the corespoinding tag from notes
    final notesRef = _firestore.collection('notes').doc(_auth.currentUser!.uid);
    final notes = await notesRef.get();
    for (var note in notes['user_notes']) {
      final tagNote = List<String>.from(note['tags'] ?? []);
      if (tagNote.contains(tag)) {
        tagNote.remove(tag);
        await notesRef.update({
          'user_notes': FieldValue.arrayRemove([note]),
        });
        await notesRef.update({
          'user_notes': FieldValue.arrayUnion([
            {
              'id': note['id'],
              'title': note['title'],
              'content': note['content'],
              'contentRich': note['contentRich'],
              'password': note['password'],
              'trashed': note['trashed'],
              'pinned': note['pinned'],
              'tags': tagNote,
              'reminder': note['reminder'],
              'dateCreated': note['dateCreated'],
              'dateModified': note['dateModified'],
            }
          ]),
        });
      }
    }
  }

  //rename tag
  Future<void> renameTag(String tag, String newTag) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_profile.tags': FieldValue.arrayRemove([tag]),
    });
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_profile.tags': FieldValue.arrayUnion([newTag]),
    });
    // update tag in notes
    final notesRef = _firestore.collection('notes').doc(_auth.currentUser!.uid);
    final notes = await notesRef.get();
    for (var note in notes['user_notes']) {
      final tagNote = List<String>.from(note['tags'] ?? []);
      if (tagNote.contains(tag)) {
        tagNote.remove(tag);
        tagNote.add(newTag);
        await notesRef.update({
          'user_notes': FieldValue.arrayRemove([note]),
        });
        await notesRef.update({
          'user_notes': FieldValue.arrayUnion([
            {
              'id': note['id'],
              'title': note['title'],
              'content': note['content'],
              'contentRich': note['contentRich'],
              'password': note['password'],
              'trashed': note['trashed'],
              'pinned': note['pinned'],
              'tags': tagNote,
              'reminder': note['reminder'],
              'dateCreated': note['dateCreated'],
              'dateModified': note['dateModified'],
            }
          ]),
        });
      }
    }
  }
}
