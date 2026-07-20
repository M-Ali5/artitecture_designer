import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    if (_isLogin) {
      await auth.signIn(email: _email.text.trim(), password: _password.text);
    } else {
      await auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        displayName: _name.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F2937), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      if (!_isLogin)
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                          ),
                          validator: (v) {
                            if (_isLogin) return null;
                            if ((v ?? '').trim().length < 2) {
                              return 'Enter valid name';
                            }
                            return null;
                          },
                        ),
                      if (!_isLogin) const SizedBox(height: 12),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (!value.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (v) {
                          if ((v ?? '').length < 6) return 'Minimum 6 chars';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (auth.error != null)
                        Text(
                          auth.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isBusy ? null : _submit,
                          child: auth.isBusy
                              ? const CircularProgressIndicator()
                              : Text(_isLogin ? 'Login' : 'Register'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? 'Create new account'
                              : 'Already have account? Login',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text.trim();
                          if (email.contains('@')) {
                            final messenger = ScaffoldMessenger.of(context);
                            await context.read<AuthController>().sendPasswordReset(email);
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
