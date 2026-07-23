import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_auth_guard.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_animated_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_users/users_body.dart';

class WebDocumentsUsers extends StatefulWidget {
  const WebDocumentsUsers({super.key});
  @override
  State<WebDocumentsUsers> createState() => _WebDocumentsUsersState();
}

class _WebDocumentsUsersState extends State<WebDocumentsUsers> {
  final _ctrl = UsersController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.load();
    _ctrl.getMyId();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return AuthGuard(
      allowedRoles: ['ADMIN', 'SUPER_ADMIN'],
      child: Scaffold(
        appBar: AnimatedAppBar(
          visible: true,
          child: UsersAppBar(service: _ctrl.svc, isWide: isWide),
        ),
        body: UsersBody(ctrl: _ctrl, isWide: isWide),
      ),
    );
  }
}
