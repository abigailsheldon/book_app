import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/* 
 * Displays the current user's profile information and their reading lists:
 * "Want to Read", "Currently Reading", and "Finished".
 */

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _fs = FirestoreService();
  AppUser? _appUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load user profile data from Firestore
  Future<void> _loadProfile() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      final profile = await _fs.getUser(user.uid);
      setState(() {
        _appUser = profile;
        _loading = false;
      });
    }
  }

  // Builds a section for a reading list category
  Widget _buildListSection(String title, List<String> bookIds) {
    return ExpansionTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      children: bookIds.isEmpty
          ? [const ListTile(title: Text('No books added.'))]
          : bookIds.map((id) => ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(id),  // TODO: replace with BookCard when integrating book details
              )).toList(),
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
                  
                  // Display user info
                  Text(
                    _appUser!.displayName ?? 'No Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _appUser!.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Reading lists
                  _buildListSection('Want to Read', _appUser!.readingListWantToRead),
                  _buildListSection('Currently Reading', _appUser!.readingListReading),
                  _buildListSection('Finished', _appUser!.readingListFinished),
                ],
              ),
            ),
    );
  }
}
