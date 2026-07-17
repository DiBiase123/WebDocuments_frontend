import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class UsersController extends ChangeNotifier {
  final _svc = WebDocumentsService();
  List<dynamic> users = [];
  bool loading = true;
  String? myUserId;

  WebDocumentsService get svc => _svc;

  List<dynamic> get admins => users
      .where((u) => u['role'] == 'ADMIN' || u['role'] == 'SUPER_ADMIN')
      .toList();

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      users = await _svc.getUsers();
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  Future<void> getMyId() async {
    myUserId = await _svc.getMyUserId();
    notifyListeners();
  }

  Future<void> updateRole(dynamic user, String newRole) async {
    try {
      await _svc.updateUserRole(
        user['id'],
        newRole,
        newRole == 'USER' ? user['adminId'] : null,
      );
      await load();
    } catch (_) {
      snack('Errore');
    }
  }

  Future<void> updateAdmin(dynamic user, String? adminId) async {
    try {
      await _svc.updateUserRole(user['id'], user['role'], adminId);
      await load();
    } catch (_) {
      snack('Errore');
    }
  }

  Color roleColor(String? role, ThemeData theme) {
    switch (role) {
      case 'SUPER_ADMIN':
        return theme.colorScheme.primary;
      case 'ADMIN':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.secondary.withValues(alpha: 0.7);
    }
  }

  IconData roleIcon(String? role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return Icons.shield;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  void snack(String msg) {
    final ctx = UsersController.navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
