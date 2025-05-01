import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/*
 *
 * Displays the user's three reading lists: "Want to Read", "Currently Reading", and "Finished".
 * Allows moving books between lists or removing them.
 */

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({Key? key}) : super(key: key);

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _fs = FirestoreService();
  AppUser? _appUser;
  bool _loading = true;
  late TabController _tabController;

  static const List<String> _tabTitles = [
    'Want to Read',
    'Reading',
    'Finished',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load the current AppUser from Firestore
  Future<void> _loadUser() async {
    final firebaseUser =
        Provider.of<UserProvider>(context, listen: false).user;
    if (firebaseUser != null) {
      final profile = await _fs.getUser(firebaseUser.uid);
      setState(() {
        _appUser = profile;
        _loading = false;
      });
    }
  }

  // Handle menu action: move or remove a book [bookId]
  Future<void> _handleAction(
      String bookId, String action, List<String> currentList) async {
    if (_appUser == null) return;
    // Copy lists
    final want = List<String>.from(_appUser!.readingListWantToRead);
    final reading = List<String>.from(_appUser!.readingListReading);
    final finished = List<String>.from(_appUser!.readingListFinished);

    // Remove from all
    want.remove(bookId);
    reading.remove(bookId);
    finished.remove(bookId);

    if (action != 'Remove') {
      
      // Determine target list
      if (action == 'Move to Want to Read') want.add(bookId);
      if (action == 'Move to Reading') reading.add(bookId);
      if (action == 'Move to Finished') finished.add(bookId);
    }

    // Update user
    final updated = AppUser(
      uid: _appUser!.uid,
      email: _appUser!.email,
      displayName: _appUser!.displayName,
      favoriteGenres: _appUser!.favoriteGenres,
      readingListWantToRead: want,
      readingListReading: reading,
      readingListFinished: finished,
    );
    await _fs.setUser(updated);
    setState(() => _appUser = updated);
  }

  // Build a list for the given [index]
  Widget _buildTab(int index) {
    if (_appUser == null) return const SizedBox.shrink();
    List<String> listIds;
    switch (index) {
      case 0:
        listIds = _appUser!.readingListWantToRead;
        break;
      case 1:
        listIds = _appUser!.readingListReading;
        break;
      case 2:
        listIds = _appUser!.readingListFinished;
        break;
      default:
        listIds = [];
    }
    if (listIds.isEmpty) {
      return const Center(child: Text('No books in this list.'));
    }
    return ListView.builder(
      itemCount: listIds.length,
      itemBuilder: (ctx, i) {
        final bookId = listIds[i];
        return ListTile(
          title: Text(bookId), // TODO: fetch Book details
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleAction(bookId, action, listIds),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'Move to Want to Read', child: Text('Move to Want to Read')),
              const PopupMenuItem(value: 'Move to Reading', child: Text('Move to Reading')),
              const PopupMenuItem(value: 'Move to Finished', child: Text('Move to Finished')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'Remove', child: Text('Remove')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reading Lists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabTitles.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(
                  _tabTitles.length, (index) => _buildTab(index)),
            ),
    );
  }
}
