import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/screens/widgets/animated_app_bar.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/widgets/logout_button.dart';

class WebDocumentsUsers extends StatefulWidget {
  const WebDocumentsUsers({super.key});
  @override
  State<WebDocumentsUsers> createState() => _WebDocumentsUsersState();
}

class _WebDocumentsUsersState extends State<WebDocumentsUsers> {
  final _svc = WebDocumentsService();
  final _auth = AuthStorage();
  List<dynamic> _users = [];
  bool _loading = true;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final auth = await _auth.loadAuthData();
    if (auth == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
      );
      return;
    }
    if (auth!['role'] != 'ADMIN' && auth['role'] != 'SUPER_ADMIN') {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WebDocumentsList()),
        );
      }
      return;
    }
    _load();
    _getMyId();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await _svc.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _getMyId() async {
    _myUserId = await _svc.getMyUserId();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateRole(dynamic user, String newRole) async {
    try {
      await _svc.updateUserRole(
        user['id'],
        newRole,
        newRole == 'USER' ? user['adminId'] : null,
      );
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Errore')));
      }
    }
  }

  Future<void> _updateAdmin(dynamic user, String? adminId) async {
    try {
      await _svc.updateUserRole(user['id'], user['role'], adminId);
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Errore')));
      }
    }
  }

  List<dynamic> get _admins => _users
      .where((u) => u['role'] == 'ADMIN' || u['role'] == 'SUPER_ADMIN')
      .toList();

  Color _roleColor(String? role) {
    final theme = Theme.of(context);
    switch (role) {
      case 'SUPER_ADMIN':
        return theme.colorScheme.primary;
      case 'ADMIN':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.secondary.withValues(alpha: 0.7);
    }
  }

  IconData _roleIcon(String? role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return Icons.shield;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AnimatedAppBar(
        visible: true,
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              if (isWide) ...[
                const Text('WebDocuments'),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Cerca utente...',
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.white.withAlpha(20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Indietro',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: LogoutButton(service: _svc),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gestione utenti :',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                ? const Center(child: Text('Nessun utente'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (_, i) {
                      final u = _users[i];
                      final isMe = u['id'] == _myUserId;
                      final role = u['role'] ?? 'USER';
                      final adminEmail = u['adminId'] != null
                          ? (_admins.firstWhere(
                                  (a) => a['id'] == u['adminId'],
                                  orElse: () => {'email': ''},
                                )['email'] ??
                                '')
                          : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _roleColor(role).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _roleColor(
                                      role,
                                    ).withValues(alpha: 0.15),
                                    child: Icon(
                                      _roleIcon(role),
                                      color: _roleColor(role),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          u['email'] ??
                                              u['username'] ??
                                              u['id']?.substring(0, 8) ??
                                              '',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _roleColor(
                                                  role,
                                                ).withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                role,
                                                style: TextStyle(
                                                  color: _roleColor(role),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            if (isMe)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.colorScheme.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Tu',
                                                  style: TextStyle(
                                                    color: theme
                                                        .colorScheme
                                                        .secondary,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (adminEmail != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.supervisor_account,
                                        size: 16,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Admin: $adminEmail',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (!isMe)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: isWide
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: _buildRoleDropdown(u),
                                            ),
                                            if (u['role'] == 'USER') ...[
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildAdminDropdown(u),
                                              ),
                                            ],
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            _buildRoleDropdown(u),
                                            if (u['role'] == 'USER') ...[
                                              const SizedBox(height: 10),
                                              _buildAdminDropdown(u),
                                            ],
                                          ],
                                        ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(dynamic u) {
    return DropdownButtonFormField<String>(
      initialValue: u['role'],
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Ruolo',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
      selectedItemBuilder: (context) {
        return const [
          Text('USER', style: TextStyle(fontSize: 14)),
          Text('ADMIN', style: TextStyle(fontSize: 14)),
          Text('SUPER_ADMIN', style: TextStyle(fontSize: 14)),
        ];
      },
      items: const [
        DropdownMenuItem(
          value: 'USER',
          child: Text('USER', style: TextStyle(fontSize: 14)),
        ),
        DropdownMenuItem(
          value: 'ADMIN',
          child: Text('ADMIN', style: TextStyle(fontSize: 14)),
        ),
        DropdownMenuItem(
          value: 'SUPER_ADMIN',
          child: Text('SUPER_ADMIN', style: TextStyle(fontSize: 14)),
        ),
      ],
      onChanged: (v) {
        if (v != null) {
          _updateRole(u, v);
        }
      },
    );
  }

  Widget _buildAdminDropdown(dynamic u) {
    return DropdownButtonFormField<String?>(
      initialValue: u['adminId'],
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Admin assegnato',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
      selectedItemBuilder: (context) {
        return <Widget>[
          const Text('Nessuno', style: TextStyle(fontSize: 14)),
          ..._admins.map(
            (a) => Text(
              a['email'] ?? a['username'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ];
      },
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Nessuno', style: TextStyle(fontSize: 14)),
        ),
        ..._admins.map(
          (a) => DropdownMenuItem(
            value: a['id'],
            child: Text(
              a['email'] ?? a['username'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
      onChanged: (v) => _updateAdmin(u, v),
    );
  }
}
