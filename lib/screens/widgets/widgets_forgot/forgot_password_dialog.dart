import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_forgot/forgot_controller.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});
  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _ctrl = ForgotController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Password dimenticata'),
      content: _ctrl.isSuccess
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, size: 60, color: Colors.green),
                SizedBox(height: 16),
                Text('Email inviata!'),
              ],
            )
          : _ctrl.isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _ctrl.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Inserisci la tua email per ricevere il link di reset.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ctrl.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _ctrl.submit(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Inserisci email'
                        : null,
                  ),
                  if (_ctrl.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _ctrl.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
      actions: _ctrl.isLoading
          ? null
          : _ctrl.isSuccess
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () => _ctrl.submit(),
                child: const Text('Invia'),
              ),
            ],
    );
  }
}
