import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_role_dropdown.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_admin_dropdown.dart';

class UsersCard extends StatelessWidget {
  final dynamic user;
  final UsersController ctrl;
  final bool isWide;

  const UsersCard({
    super.key,
    required this.user,
    required this.ctrl,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = user['id'] == ctrl.myUserId;
    final role = user['role'] ?? 'USER';
    final adminEmail = user['adminId'] != null
        ? (ctrl.admins.firstWhere(
                (a) => a['id'] == user['adminId'],
                orElse: () => {'email': ''},
              )['email'] ??
              '')
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ctrl.roleColor(role, theme).withValues(alpha: 0.3),
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
                  backgroundColor: ctrl
                      .roleColor(role, theme)
                      .withValues(alpha: 0.15),
                  child: Icon(
                    ctrl.roleIcon(role),
                    color: ctrl.roleColor(role, theme),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['email'] ??
                            user['username'] ??
                            user['id']?.substring(0, 8) ??
                            '',
                        style: theme.textTheme.bodyMedium?.copyWith(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ctrl
                                  .roleColor(role, theme)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                color: ctrl.roleColor(role, theme),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isMe)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Tu',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
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
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(
                            child: UsersRoleDropdown(
                              role: role,
                              onChanged: (v) => ctrl.updateRole(user, v),
                            ),
                          ),
                          if (role == 'USER') ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: UsersAdminDropdown(
                                adminId: user['adminId'],
                                admins: ctrl.admins,
                                onChanged: (v) => ctrl.updateAdmin(user, v),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Column(
                        children: [
                          UsersRoleDropdown(
                            role: role,
                            onChanged: (v) => ctrl.updateRole(user, v),
                          ),
                          if (role == 'USER') ...[
                            const SizedBox(height: 10),
                            UsersAdminDropdown(
                              adminId: user['adminId'],
                              admins: ctrl.admins,
                              onChanged: (v) => ctrl.updateAdmin(user, v),
                            ),
                          ],
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
