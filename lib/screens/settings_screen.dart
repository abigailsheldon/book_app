import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/*
 * Allows the user to view and update profile settings (display name, favorite genres)
 * and to log out of the app.
 */

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final FirestoreService _fs = FirestoreService();
  bool _loading = false;
  AppUser? _appUser;
  List<String> _selectedGenres = [];

  // Pre-defined list of genres for selection
  static const List<String> _allGenres = [
    'Fiction', 'Non-fiction', 'Sci-Fi', 'Fantasy', 'Mystery', 'Romance',
    'Horror', 'Biography', 'History', 'Science'
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /*
   * Loads the AppUser document from Firestore and initializes form fields.
   */
  Future<void> _loadUser() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      final appUser = await _fs.getUser(user.uid);
      setState(() {
        _appUser = appUser;
        _nameController.text = appUser.displayName ?? '';
        _selectedGenres = List.from(appUser.favoriteGenres);
      });
    }
  }

  /*
   * Saves the updated AppUser back to Firestore.
   */
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate() || _appUser == null) return;
    setState(() => _loading = true);

    final updatedUser = AppUser(
      uid: _appUser!.uid,
      email: _appUser!.email,
      displayName: _nameController.text.trim(),
      favoriteGenres: _selectedGenres,
      readingListWantToRead: _appUser!.readingListWantToRead,
      readingListReading: _appUser!.readingListReading,
      readingListFinished: _appUser!.readingListFinished,
    );

    await _fs.setUser(updatedUser);
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Settings saved.')));
  }

  /*
   * Logs the user out via UserProvider and navigates to the login screen.
   */
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
                    Text(
                      'Email: ${_appUser!.email}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Editable display name field
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

                    // Favorite genres multi-select via FilterChips
                    const Text('Favorite Genres'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _allGenres.map((genre) {
                        return FilterChip(
                          label: Text(genre),
                          selected: _selectedGenres.contains(genre),
                          onSelected: (yes) {
                            setState(() {
                              if (yes) {
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

                    // Save settings button
                    ElevatedButton(
                      onPressed: _loading ? null : _saveSettings,
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
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
