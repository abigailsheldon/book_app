import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/*
 * SettingsScreen
 * Allows user to update display name and favorite genres, and to log out.
 */
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();
  bool _loading = false;
  AppUser? _appUser;
  List<String> _selectedGenres = [];

  static const List<String> _allGenres = [
    'Fiction', 'Non-fiction', 'Sci-Fi', 'Fantasy', 'Mystery',
    'Romance', 'Horror', 'Biography', 'History', 'Science'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = Provider.of<UserProvider>(context, listen: false).user;
    if (firebaseUser != null) {
      final userData = await _firestore.getUser(firebaseUser.uid);
      setState(() {
        _appUser = userData;
        _nameController.text = userData.displayName ?? '';
        _selectedGenres = List.from(userData.favoriteGenres);
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate() || _appUser == null) return;
    setState(() => _loading = true);
    final updated = AppUser(
      uid: _appUser!.uid,
      email: _appUser!.email,
      displayName: _nameController.text.trim(),
      favoriteGenres: _selectedGenres,
      readingListWantToRead: _appUser!.readingListWantToRead,
      readingListReading: _appUser!.readingListReading,
      readingListFinished: _appUser!.readingListFinished,
    );
    await _firestore.setUser(updated);
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings saved.')));
  }

  Future<void> _logout() async {
    await Provider.of<UserProvider>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _appUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // Display user email (read-only)
                    Text('Email: ${_appUser!.email}'),
                    const SizedBox(height: 16),
                    
                    // Display name input
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val != null && val.trim().isNotEmpty
                              ? null
                              : 'Enter a display name',
                    ),
                    const SizedBox(height: 24),
                    
                    // Favorite genres selection
                    const Text('Favorite Genres'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _allGenres.map((genre) {
                        return FilterChip(
                          label: Text(genre),
                          selected: _selectedGenres.contains(genre),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedGenres.add(genre);
                              } else {
                                _selectedGenres.remove(genre);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _loading ? null : _saveSettings,
                      child: _loading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)
                          : const Text('Save Settings'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Logout button
                    OutlinedButton(
                      onPressed: _logout,
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}