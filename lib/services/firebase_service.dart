import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

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
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(userCredential.user!.uid)
          .set({
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

  //get tags from firestore
  Future<List<String>> getTags() async {
    final tagsSnapshot =
        await _firestore.collection('notes').doc(_auth.currentUser!.uid).get();
    final tagsData = tagsSnapshot.data() as Map<String, dynamic>;
    final tagsList = tagsData['user_profile']['tags'] as List<dynamic>;
    return tagsList.cast<String>();
  }

  //add note
  //! THEM THUOC TINH VAO NOTE THI PHAI QUA DAY UPDATE
  Future<void> addNote(
    String title,
    QuillController controller,
    List<String> selectedTags,
  ) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayUnion([
        {
          'id': const Uuid().v4(),
          'title': title,
          'content': controller.document.toPlainText(),
          'contentRich': jsonEncode(controller.document.toDelta().toJson()),
          'tags': selectedTags,
          'trashed': false,
          'pinned': false,
          'dateCreated': DateTime.now(),
          'dateModified': DateTime.now(),
        }
      ]),
    });
  }

  //!KHONG CAN CHINH O DAY
  Future<void> updateNote(
      {required Note oldNote, required Note newNote}) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayRemove([oldNote.toFirestore()]),
    });
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayUnion([newNote.toFirestore()]),
    });
  }

  //!KHONG CAN CHINH O DAY
  Future<void> deleteNote({
    required Note note,
  }) async {
    await _firestore.collection('notes').doc(_auth.currentUser!.uid).update({
      'user_notes': FieldValue.arrayRemove([note.toFirestore()]),
    });
  }

  //create tag
  //!KHONG CAN CHINH O DAY
  Future<void> createTag(String tag) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(_auth.currentUser!.uid)
        .update({
      'user_profile.tags': FieldValue.arrayUnion(
        [tag],
      ),
    });
  }

  //delete tag
  Future<void> deleteTag(String tag) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(_auth.currentUser!.uid)
        .update({
      'user_profile.tags': FieldValue.arrayRemove(
        [tag],
      ),
    });
    //! UPDATE
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
              'trashed': note['trashed'],
              'pinned': note['pinned'],
              'tags': tagNote,
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
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(_auth.currentUser!.uid)
        .update({
      'user_profile.tags': FieldValue.arrayRemove([tag]),
    });
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(_auth.currentUser!.uid)
        .update({
      'user_profile.tags': FieldValue.arrayUnion([newTag]),
    });
    //! UPDATE
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
              'trashed': note['trashed'],
              'pinned': note['pinned'],
              'tags': tagNote,
              'dateCreated': note['dateCreated'],
              'dateModified': note['dateModified'],
            }
          ]),
        });
      }
    }
  }
}
