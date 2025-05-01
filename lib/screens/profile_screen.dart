import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/*
 * ProfileScreen
 * Displays the user's display name, email, and their three reading lists.
 */
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestore = FirestoreService();
  AppUser? _appUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final firebaseUser =
        Provider.of<UserProvider>(context, listen: false).user;
    if (firebaseUser != null) {
      final userData = await _firestore.getUser(firebaseUser.uid);
      setState(() {
        _appUser = userData;
        _loading = false;
      });
    }
  }

  Widget _buildListSection(String title, List<String> bookIds) {
    return ExpansionTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      children: bookIds.isEmpty
          ? [const ListTile(title: Text('No books in this list.'))]
          : bookIds
              .map((id) => ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(id),
                  ))
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display name
                  Text(
                    _appUser!.displayName ?? 'No Display Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    _appUser!.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Reading lists
                  _buildListSection(
                      'Want to Read', _appUser!.readingListWantToRead),
                  _buildListSection(
                      'Currently Reading', _appUser!.readingListReading),
                  _buildListSection('Finished', _appUser!.readingListFinished),
                ],
              ),
            ),
    );
  }
}