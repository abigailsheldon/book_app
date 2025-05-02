import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../models/user.dart';
import '../screens/book_detail_screen.dart';

/*
 * ReadingListScreen
 * Shows the user's "Want to Read", "Reading", and "Finished" lists.
 * Allows moving books between lists or removing them.
 */
class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({Key? key}) : super(key: key);

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = ['Want to Read', 'Reading', 'Finished'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final bookProv = context.watch<BookProvider>();
    final appUser = userProv.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reading Lists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: appUser == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(
                _tabs.length,
                (index) => _buildListTab(
                  context,
                  index,
                  appUser,
                  bookProv,
                  userProv,
                ),
              ),
            ),
    );
  }

  Widget _buildListTab(
    BuildContext context,
    int index,
    AppUser appUser,
    BookProvider bookProv,
    UserProvider userProv,
  ) {
    final listOfIds = index == 0
        ? appUser.readingListWantToRead
        : index == 1
            ? appUser.readingListReading
            : appUser.readingListFinished;

    if (listOfIds.isEmpty) {
      return const Center(child: Text('No books in this list.'));
    }

    return FutureBuilder<List<Book>>(
      future: Future.wait(
        listOfIds.map((id) => bookProv.fetchBookById(id)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        final books = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, i) {
            final book = books[i];
            return ListTile(
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(book: book),
                    ),
                  );
                },
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                        book.coverUrl,
                        width: 40,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(width: 40),
              ),
              title: Text(book.title),
              subtitle: Text('by ${book.author}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => userProv.updateReadingList(
                  book.id,
                  value,
                ),
                itemBuilder: (_) => [
                  for (var tab in _tabs)
                    PopupMenuItem(
                      value: tab,
                      child: Text('Move to $tab'),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'Remove',
                    child: Text('Remove'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
