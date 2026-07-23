import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';
import 'package:webdocuments/screens/webdocuments_register.dart';
import 'package:webdocuments/screens/widgets/forgot_password_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:webdocuments/dev_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebDocumentsLogin extends StatefulWidget {
  const WebDocumentsLogin({super.key});
  @override
  State<WebDocumentsLogin> createState() => _WebDocumentsLoginState();
}

class _WebDocumentsLoginState extends State<WebDocumentsLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _service = WebDocumentsService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe && savedEmail != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword ?? '';
      _rememberMe = true;
      if (mounted) {
        setState(() {});
      }
    } else if (kDebugMode) {
      _emailController.text = DevCredentials.email;
      _passwordController.text = DevCredentials.password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _service.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passwordController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }

      final roleData = await _service.getMyRole();
      String userRole = roleData['role'] ?? 'USER';
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => userRole == 'ADMIN' || userRole == 'SUPER_ADMIN'
              ? const WebDocumentsDashboard()
              : const WebDocumentsList(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'WebDocuments',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Area riservata',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 40),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Inserisci e-mail';
                              }
                              if (!_isValidEmail(v.trim())) {
                                return 'Formato e-mail errato';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Inserisci password'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Text(
                                  'Ricordami',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => const ForgotPasswordDialog(),
                                ),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'Password dimenticata?',
                                    style: TextStyle(
                                      color: theme.colorScheme.secondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('ENTRA'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Non hai un account? ',
                                style: theme.textTheme.bodySmall,
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const WebDocumentsRegister(),
                                      ),
                                    ),
                                child: Text(
                                  'Registrati',
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
