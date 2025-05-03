// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final userProv = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Email field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Invalid email',
                  onSaved: (v) => _email = v!.trim(),
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6
                      ? null
                      : 'Password must be at least 6 characters',
                  onSaved: (v) => _password = v!,
                ),
                const SizedBox(height: 16),

                // Inline error message
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Log In button
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          // Validate & save form
                          if (!_formKey.currentState!.validate()) return;
                          _formKey.currentState!.save();

                          setState(() {
                            _loading = true;
                            _errorText = null;
                          });

                          // Attempt login
                          final success =
                              await userProv.login(_email, _password);

                          setState(() => _loading = false);

                          if (success) {
                            // Navigate on success
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            // Show provider error
                            setState(() {
                              _errorText = userProv.errorMessage;
                            });
                          }
                        },
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log In'),
                ),
                const SizedBox(height: 12),

                // Link to Sign Up
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/signup'),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
