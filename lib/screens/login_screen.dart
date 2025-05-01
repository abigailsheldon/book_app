import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/*
 * Login form, handles validation, displays errors,
 * and calls UserProvider.login when submitting.
 */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val != null && val.contains('@') ? null : 'Invalid email',
                onSaved: (val) => _email = val!.trim(),
              ),
              // Password input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) =>
                    val != null && val.length >= 6 ? null : 'Min 6 chars',
                onSaved: (val) => _password = val!,
              ),
              const SizedBox(height: 20),
              // Error message
              if (userProv.errorMessage != null)
                Text(userProv.errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              // Login button
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() => _loading = true);
                          final success =
                              await userProv.login(_email, _password);
                          setState(() => _loading = false);
                          if (success) Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                child:
                    _loading ? const CircularProgressIndicator() : const Text('Login'),
              ),
              // Navigate to signup
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
