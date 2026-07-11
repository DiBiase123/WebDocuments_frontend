import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:webdocuments/navigation/go_router.dart';
import 'package:webdocuments/theme/app_theme.dart';

void main() => runApp(const WebDocumentsApp());

class WebDocumentsApp extends StatelessWidget {
  const WebDocumentsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WebDocuments',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it')],
      locale: const Locale('it'),
    );
  }
}
