import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class WebDocumentsUsers extends StatefulWidget {
  const WebDocumentsUsers({super.key});
  @override
  State<WebDocumentsUsers> createState() => _WebDocumentsUsersState();
}

class _WebDocumentsUsersState extends State<WebDocumentsUsers> {
  final _svc = WebDocumentsService();
  List<dynamic> _users = [];
  bool _loading = true;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _load();
    _getMyId();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
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
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _getMyId() async {
    _myUserId = await _svc.getMyUserId();
    if (mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestione utenti')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text('Nessun utente'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (_, i) {
                final u = _users[i];
                final isMe = u['userId'] == _myUserId;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      u['email'] ??
                          u['username'] ??
                          u['userId']?.substring(0, 8) ??
                          '',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ruolo: ${u['role']}'),
                        if (u['adminId'] != null)
                          Text(
                            'Admin: ${_admins.firstWhere((a) => a['userId'] == u['adminId'], orElse: () => {'email': ''})['email'] ?? ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: isMe
                        ? Text(
                            u['role'] ?? '',
                            style: const TextStyle(color: Colors.white54),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButton<String>(
                                value: u['role'],
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'USER',
                                    child: Text('USER'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ADMIN',
                                    child: Text('ADMIN'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    _updateRole(u, v);
                                  }
                                },
                              ),
                              if (u['role'] == 'USER') ...[
                                const SizedBox(width: 8),
                                DropdownButton<String?>(
                                  value: u['adminId'],
                                  underline: const SizedBox.shrink(),
                                  hint: const Text('Admin'),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('Nessuno'),
                                    ),
                                    ..._admins.map(
                                      (a) => DropdownMenuItem(
                                        value: a['userId'],
                                        child: Text(
                                          a['email'] ?? a['username'] ?? '',
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    _updateAdmin(u, v);
                                  },
                                ),
                              ],
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }
}
