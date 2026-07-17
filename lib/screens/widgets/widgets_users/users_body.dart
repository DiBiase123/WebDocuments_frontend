import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_card.dart';

class UsersBody extends StatelessWidget {
  final UsersController ctrl;
  final bool isWide;

  const UsersBody({super.key, required this.ctrl, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: ctrl.loading
              ? const Center(child: CircularProgressIndicator())
              : ctrl.users.isEmpty
              ? const Center(child: Text('Nessun utente'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.users.length,
                  itemBuilder: (_, i) => UsersCard(
                    user: ctrl.users[i],
                    ctrl: ctrl,
                    isWide: isWide,
                  ),
                ),
        ),
      ],
    );
  }
}
