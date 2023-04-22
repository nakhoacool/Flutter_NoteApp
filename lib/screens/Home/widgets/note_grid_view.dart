import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../models/note.dart';
import '../../../services/firebase_service.dart';
import '../detail_screen.dart';
import 'note_widget.dart';

class NoteGridView extends StatefulWidget {
  const NoteGridView({
    super.key,
    required this.notes,
    required this.title,
  });

  final List notes;
  final String title;

  @override
  State<NoteGridView> createState() => _NoteGridViewState();
}

class _NoteGridViewState extends State<NoteGridView> {
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _controllerPassword;
  late TextEditingController _controllerConfirmPassword;
  late TextEditingController _controllerOldPassword;

  final _formKeySetPassword = GlobalKey<FormState>();
  final _formKeyEnterPassword = GlobalKey<FormState>();
  final _formKeyChangePassword = GlobalKey<FormState>();

  @override
  void initState() {
    _controllerPassword = TextEditingController();
    _controllerConfirmPassword = TextEditingController();
    _controllerOldPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerPassword.dispose();
    _controllerConfirmPassword.dispose();
    _controllerOldPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return MasonryGridView.count(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        scrollDirection: Axis.vertical,
        itemCount: widget.notes.length,
        itemBuilder: (context, index) {
          final note = widget.notes[index] as Map<String, dynamic>;
          return GestureDetector(
            onTap: () async {
              if (note['password'] == "") {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(
                            note: Note.fromFirestore(note),
                            title: widget.title)));
                if (result != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Note $result'),
                    ),
                  );
                }
              } else {
                var validation = await enterPasswordAlertDialog();
                if (validation != null) {
                  if (validation['password'] == note['password']) {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NoteDetailScreen(
                                note: Note.fromFirestore(note),
                                title: widget.title)));
                    if (result != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Note $result'),
                        ),
                      );
                    }
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Wrong password'),
                      ),
                    );
                  }
                }
              }
            },
            onLongPress: widget.title == 'Home'
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
                            if (note['password'] == "") ...[
                              ListTile(
                                leading: const Icon(Icons.lock),
                                title: const Text('Protect'),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  var result =
                                      await setPasswordAlertDialog(ctx);
                                  if (result != false) {
                                    await _firebaseService.protectNote(
                                        note, result['password']);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Note has been protected'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ] else ...[
                              ListTile(
                                leading: const Icon(Icons.lock_reset),
                                title: const Text('Change password'),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  var result = await changePasswordAlertDialog(
                                      context, note);
                                  if (result != false) {
                                    await _firebaseService.protectNote(
                                        note, result['password']);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Password has been changed'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.lock_open),
                                title: const Text('Unprotect'),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  var result = await enterPasswordAlertDialog();
                                  if (result != null) {
                                    if (result['password'] ==
                                        note['password']) {
                                      await _firebaseService.protectNote(
                                          note, '');
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Note has been unprotected'),
                                        ),
                                      );
                                    } else {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Wrong password'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
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

  Future<dynamic> setPasswordAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Set password'),
            content: Form(
                key: _formKeySetPassword,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: _controllerPassword,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: _controllerConfirmPassword,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter confirm password';
                      }
                      if (value != _controllerPassword.text) {
                        return 'Password does not match';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                ])),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx, false);
                  _controllerPassword.clear();
                  _controllerConfirmPassword.clear();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKeySetPassword.currentState?.validate() ?? false) {
                    Navigator.pop(
                        ctx, {"password": _controllerConfirmPassword.text});
                    _formKeySetPassword.currentState?.reset();
                  }
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  Future<dynamic> changePasswordAlertDialog(BuildContext context, note) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Change password'),
            content: Form(
                key: _formKeyChangePassword,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    obscureText: true,
                    controller: _controllerOldPassword,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Old password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter old password';
                      }
                      if (value != note['password']) {
                        return 'Old password does not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: _controllerPassword,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: _controllerConfirmPassword,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter confirm password';
                      }
                      if (value != _controllerPassword.text) {
                        return 'Password does not match';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                ])),
            actions: [
              TextButton(
                onPressed: () {
                  _controllerPassword.clear();
                  _controllerConfirmPassword.clear();
                  _controllerOldPassword.clear();
                  Navigator.pop(ctx, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKeyChangePassword.currentState?.validate() ??
                      false) {
                    Navigator.pop(
                        ctx, {"password": _controllerConfirmPassword.text});
                    _formKeyChangePassword.currentState?.reset();
                  }
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  Future<dynamic> enterPasswordAlertDialog() {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Enter password'),
            content: Form(
              key: _formKeyEnterPassword,
              child: TextFormField(
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: _controllerPassword,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _controllerPassword.clear();
                  Navigator.pop(ctx);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKeyEnterPassword.currentState!.validate()) {
                    Navigator.pop(ctx, {
                      'password': _controllerPassword.text,
                    });
                    _formKeyEnterPassword.currentState!.reset();
                  }
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }
}
