import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_cubit.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/validation/input_validators.dart';
import '../../../../core/validation/input_sanitizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialMessage});

  final String? initialMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInfo(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit(AuthCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;

    final username =
        InputSanitizer.sanitizeUsername(_usernameController.text.trim());
    final password = _passwordController.text;

    await cubit.login(username: username, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            _showInfo(state.errorMessage!);
          } else if (state.message != null &&
              state.status != AuthStatus.authenticated) {
            _showInfo(state.message!);
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Secure Login',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Access to the POS console is restricted to authorized users.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => InputValidators.combine(
                            [
                              (v) => InputValidators.required(v,
                                  fieldName: 'Username'),
                              InputValidators.username,
                            ],
                            value,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (value) => InputValidators.combine(
                            [
                              (v) => InputValidators.required(v,
                                  fieldName: 'Password'),
                              InputValidators.password,
                            ],
                            value,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _showInfo(
                                'Contact your administrator to reset credentials.',
                              );
                            },
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  _submit(cubit);
                                },
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
