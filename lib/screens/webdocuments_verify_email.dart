import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_auth_form_wrapper.dart';

class WebDocumentsVerifyEmail extends StatefulWidget {
  final String token;
  const WebDocumentsVerifyEmail({super.key, required this.token});
  @override
  State<WebDocumentsVerifyEmail> createState() =>
      _WebDocumentsVerifyEmailState();
}

class _WebDocumentsVerifyEmailState extends State<WebDocumentsVerifyEmail> {
  final _service = WebDocumentsService();
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    try {
      await _service.verifyEmail(widget.token);
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
          );
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifica Email')),
      body: AuthFormWrapper(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _isSuccess
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 20),
                  Text('Account verificato! Verrai reindirizzato al login...'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(_errorMessage ?? 'Errore'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const WebDocumentsLogin(),
                      ),
                    ),
                    child: const Text('Vai al Login'),
                  ),
                ],
              ),
      ),
    );
  }
}
