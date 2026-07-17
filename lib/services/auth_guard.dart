import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final List<String>? allowedRoles;

  const AuthGuard({super.key, required this.child, this.allowedRoles});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final _auth = AuthStorage();
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final auth = await _auth.loadAuthData();
    if (!mounted) return;
    if (auth == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
      );
      return;
    }
    if (widget.allowedRoles != null &&
        !widget.allowedRoles!.contains(auth['role'])) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
      );
      return;
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}
