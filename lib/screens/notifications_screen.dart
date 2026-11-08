import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().s;
    return Scaffold(
      appBar: AppBar(title: Text(s.notifications)),
      body: Center(
        child: EmptyState(
          message: s.noNotifications,
          icon: Icons.notifications_none_rounded,
        ),
      ),
    );
  }
}
