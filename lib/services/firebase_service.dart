import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

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

  //get selected tags of the note

  //add note
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
}
