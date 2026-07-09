import 'package:go_router/go_router.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';

final goRouter = GoRouter(
  initialLocation: '/webdocuments',
  routes: [
    GoRoute(
      path: '/webdocuments',
      name: 'webdocuments',
      builder: (context, state) => const WebDocumentsLogin(),
    ),
    GoRoute(
      path: '/webdocuments/list',
      name: 'webdocuments-list',
      builder: (context, state) => const WebDocumentsList(),
    ),
    GoRoute(
      path: '/webdocuments/dashboard',
      name: 'webdocuments-dashboard',
      builder: (context, state) => const WebDocumentsDashboard(),
    ),
  ],
);
