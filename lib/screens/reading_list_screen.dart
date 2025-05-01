import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/*
 * ReadingListScreen
 * Shows the user's "Want to Read", "Currently Reading", and "Finished" lists.
 * Allows moving books between lists or removing them.
 */
class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({Key? key}) : super(key: key);

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestore = FirestoreService();
  AppUser? _appUser;
  bool _loading = true;
  late TabController _tabController;
  static const _tabs = ['Want to Read', 'Reading', 'Finished'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final firebaseUser = Provider.of<UserProvider>(context, listen: false).user;
    if (firebaseUser != null) {
      final userData = await _firestore.getUser(firebaseUser.uid);
      setState(() {
        _appUser = userData;
        _loading = false;
      });
    }
  }

  Future<void> _updateList(String bookId, String action) async {
    if (_appUser == null) return;
    // Copy existing lists
    final want = List<String>.from(_appUser!.readingListWantToRead);
    final reading = List<String>.from(_appUser!.readingListReading);
    final finished = List<String>.from(_appUser!.readingListFinished);
    // Remove from all
    want.remove(bookId);
    reading.remove(bookId);
    finished.remove(bookId);
    // Add to target
    if (action != 'Remove') {
      switch (action) {
        case 'Want to Read':
          want.add(bookId);
          break;
        case 'Reading':
          reading.add(bookId);
          break;
        case 'Finished':
          finished.add(bookId);
          break;
      }
    }
    final updated = AppUser(
      uid: _appUser!.uid,
      email: _appUser!.email,
      displayName: _appUser!.displayName,
      favoriteGenres: _appUser!.favoriteGenres,
      readingListWantToRead: want,
      readingListReading: reading,
      readingListFinished: finished,
    );
    await _firestore.setUser(updated);
    setState(() => _appUser = updated);
  }

  Widget _buildTabContent(int index) {
    if (_appUser == null) return const SizedBox.shrink();
    final lists = [
      _appUser!.readingListWantToRead,
      _appUser!.readingListReading,
      _appUser!.readingListFinished,
    ];
    final currentList = lists[index];
    if (currentList.isEmpty) {
      return const Center(child: Text('No books in this list.'));
    }
    return ListView.separated(
      itemCount: currentList.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (ctx, i) {
        final id = currentList[i];
        return ListTile(
          title: Text(id), // TODO: replace with BookCard for real details
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _updateList(id, value),
            itemBuilder: (_) => [
              for (var tab in _tabs) PopupMenuItem(value: tab, child: Text('Move to $tab')),
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
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children:
                  List.generate(_tabs.length, (index) => _buildTabContent(index)),
            ),
    );
  }
}