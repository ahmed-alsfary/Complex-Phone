import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
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
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              selectedIcon: Icon(Icons.home_work_rounded),
              label: 'وحدتي',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments_rounded),
              label: 'الأقساط',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description_rounded),
              label: 'العقود',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
