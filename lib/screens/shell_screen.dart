import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../providers/settings_provider.dart';
import 'contracts_screen.dart';
import 'home_screen.dart';
import 'installments_screen.dart';
import 'profile_screen.dart';
import 'unit_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;

  static const _tabs = [
    ResidentTab.home,
    ResidentTab.unit,
    ResidentTab.installments,
    ResidentTab.contracts,
    ResidentTab.profile,
  ];

  final pages = const [
    HomeScreen(),
    UnitScreen(),
    InstallmentsScreen(),
    ContractsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTab(0));
  }

  void _loadTab(int i) {
    final auth = context.read<AuthProvider>();
    context.read<ResidentProvider>().loadTab(auth, _tabs[i]);
  }

  void _onDestinationSelected(int i) {
    if (i == index) {
      _loadTab(i);
      return;
    }
    setState(() => index = i);
    _loadTab(i);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().s;
    final surface = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brand.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: s.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.home_work_outlined),
              selectedIcon: const Icon(Icons.home_work_rounded),
              label: s.myUnit,
            ),
            NavigationDestination(
              icon: const Icon(Icons.payments_outlined),
              selectedIcon: const Icon(Icons.payments_rounded),
              label: s.installments,
            ),
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              selectedIcon: const Icon(Icons.description_rounded),
              label: s.contracts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: s.profile,
            ),
          ],
        ),
      ),
    );
  }
}
