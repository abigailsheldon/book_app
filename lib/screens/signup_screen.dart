import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/*
 * Sign-up form, handles validation, displays errors,
 * and calls UserProvider.signup when submitting.
 */

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email input field with validation
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val != null && val.contains('@') ? null : 'Invalid email',
                onSaved: (val) => _email = val!.trim(),
              ),
              const SizedBox(height: 16),
              
              // Password field requiring at least 6 characters
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) => val != null && val.length >= 6
                    ? null
                    : 'Min 6 characters',
                onSaved: (val) => _password = val!,
              ),
              const SizedBox(height: 24),
              
              // Display error message if signup fails
              if (userProv.errorMessage != null)
                Text(
                  userProv.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              
              // Sign-up button triggers provider.signup
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() => _loading = true);
                          final success =
                              await userProv.signup(_email, _password);
                          setState(() => _loading = false);
                          if (success) {
                            Navigator.pushReplacementNamed(
                                context, '/home');
                          }
                        }
                      },
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 12),
              
              // Button to navigate back to login
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/login',
                ),
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  // TODO: Add UI logic

}