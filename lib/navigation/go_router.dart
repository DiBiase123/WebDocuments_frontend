import 'package:go_router/go_router.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/webdocuments_verify_email.dart';
import 'package:webdocuments/screens/webdocuments_users.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/webdocuments_enti.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_controller.dart';
import 'package:webdocuments/screens/webdocuments_reset_password.dart';

final goRouter = GoRouter(
  navigatorKey: ExtractController.navigatorKey,
  initialLocation: '/webdocuments',
  routes: [
    GoRoute(
      path: '/webdocuments',
      name: 'webdocuments',
      builder: (context, state) => const WebDocumentsLogin(),
    ),
    GoRoute(
      path: '/verify-email/:token',
      name: 'verify-email',
      builder: (context, state) =>
          VerifyEmailScreen(token: state.pathParameters['token']!),
    ),
    GoRoute(
      path: '/webdocuments/list',
      name: 'webdocuments-list',
      builder: (context, state) => const WebDocumentsList(),
    ),
    GoRoute(
      path: '/webdocuments/enti',
      name: 'webdocuments-enti',
      builder: (context, state) => const WebDocumentsEnti(),
    ),
    GoRoute(
      path: '/webdocuments/dashboard',
      name: 'webdocuments-dashboard',
      builder: (context, state) => const WebDocumentsDashboard(),
    ),
    GoRoute(
      path: '/webdocuments/users',
      name: 'webdocuments-users',
      builder: (context, state) => const WebDocumentsUsers(),
    ),
    GoRoute(
      path: '/reset-password/:token',
      name: 'reset-password',
      builder: (context, state) =>
          ResetPasswordScreen(token: state.pathParameters['token']!),
    ),
  ],
);
