import 'package:flutter/material.dart';
import 'package:webdocuments/navigation/go_router.dart';

void main() => runApp(const WebDocumentsApp());

class WebDocumentsApp extends StatelessWidget {
  const WebDocumentsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WebDocuments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF16213E),
      ),
      routerConfig: goRouter,
    );
  }
}
