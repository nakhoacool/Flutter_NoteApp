import '../../models/note.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  List<Note> _notes = [];
  List<Note> _searchResult = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _getNotes() async {
    setState(() {
      _isLoading = true;
    });
    _notes = await _firebaseService.getNotes();
    setState(() {
      _isLoading = false;
    });
  }

  void _searchNotes() {
    final search = _searchController.text;
    if (search.isEmpty) {
      setState(() {
        _searchResult = [];
      });
      return;
    }
    final result = _notes.where((element) {
      final titleLower = element.title.toLowerCase();
      final contentLower = element.content.toLowerCase();
      final searchLower = search.toLowerCase();
      return titleLower.contains(searchLower) ||
          contentLower.contains(searchLower);
    }).toList();
    setState(() {
      _searchResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        _searchNotes();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _searchResult.isEmpty
                      ? Center(
                          child:
                              Text('No result found ${_searchController.text}'),
                        )
                      : ListView.builder(
                          itemCount: _searchResult.length,
                          itemBuilder: (context, index) {
                            final note = _searchResult[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoteDetailScreen(
                                        note: note, title: 'Search'),
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(note.title),
                                subtitle: Text(note.content),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
