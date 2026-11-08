import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../services/visitor_service.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import 'create_visitor_pass_screen.dart';
import 'visitor_pass_detail_screen.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  bool _loading = true;
  String? _error;
  List<VisitorPass> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await context.read<VisitorService>().list();
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<VisitorPass>(
      MaterialPageRoute(builder: (_) => const CreateVisitorPassScreen()),
    );
    if (created != null && mounted) {
      await _load();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VisitorPassDetailScreen(pass: created)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصاريح الزوار'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text('تصريح جديد'),
        backgroundColor: AppTheme.brandMid,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: AppTheme.brandMid,
        onRefresh: _load,
        child: _loading && _items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null && _items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                      EmptyState(
                        message: _error!,
                        icon: Icons.error_outline_rounded,
                        actionLabel: 'إعادة المحاولة',
                        onAction: _load,
                      ),
                    ],
                  )
                : _items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
                          EmptyState(
                            message: 'لا توجد تصاريح بعد.\nأنشئ تصريحاً لضيفك ليمر عبر البوابة.',
                            icon: Icons.badge_outlined,
                            actionLabel: 'إنشاء تصريح',
                            onAction: _openCreate,
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final pass = _items[i];
                          return _VisitorTile(
                            pass: pass,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VisitorPassDetailScreen(pass: pass),
                                ),
                              );
                              if (mounted) _load();
                            },
                          );
                        },
                      ),
      ),
    );
  }
}

class _VisitorTile extends StatelessWidget {
  const _VisitorTile({required this.pass, required this.onTap});

  final VisitorPass pass;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tone;
    final String status;
    if (pass.isUsed) {
      tone = AppTheme.muted;
      status = 'مستخدم';
    } else if (pass.isExpired) {
      tone = AppTheme.danger;
      status = 'منتهي';
    } else {
      tone = AppTheme.success;
      status = 'ساري';
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  pass.isShareable ? Icons.qr_code_rounded : Icons.qr_code_2_outlined,
                  color: tone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pass.visitorName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if ((pass.visitReason ?? '').isNotEmpty) pass.visitReason!,
                        'حتى ${formatDate(pass.validUntil)}',
                      ].join(' · '),
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: tone,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
