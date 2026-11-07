import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';

class InstallmentsScreen extends StatefulWidget {
  const InstallmentsScreen({super.key});

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  int _filter = 0; // 0 all, 1 unpaid, 2 paid, 3 overdue

  Color _colorFor(int? status) {
    switch (status) {
      case 2:
        return AppTheme.success;
      case 4:
        return AppTheme.danger;
      case 3:
        return AppTheme.info;
      default:
        return AppTheme.warning;
    }
  }

  List<InstallmentItem> _filtered(List<InstallmentItem> items) {
    switch (_filter) {
      case 1:
        return items.where((i) => i.status == 1 || i.status == 3).toList();
      case 2:
        return items.where((i) => i.status == 2).toList();
      case 3:
        return items.where((i) => i.status == 4).toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resident = context.watch<ResidentProvider>();
    final items = resident.installments;
    final filtered = _filtered(items);

    return Scaffold(
      appBar: AppBar(title: Text('الأقساط (${items.length})')),
      body: RefreshIndicator(
        color: AppTheme.brandMid,
        onRefresh: () =>
            context.read<ResidentProvider>().loadInstallments(context.read<AuthProvider>()),
        child: resident.loading && items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EmptyState(message: resident.error ?? 'لا توجد أقساط'),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 52,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          children: [
                            _FilterChip(
                              label: 'الكل',
                              selected: _filter == 0,
                              onTap: () => setState(() => _filter = 0),
                            ),
                            _FilterChip(
                              label: 'غير مدفوعة',
                              selected: _filter == 1,
                              onTap: () => setState(() => _filter = 1),
                            ),
                            _FilterChip(
                              label: 'مدفوعة',
                              selected: _filter == 2,
                              onTap: () => setState(() => _filter = 2),
                            ),
                            _FilterChip(
                              label: 'متأخرة',
                              selected: _filter == 3,
                              onTap: () => setState(() => _filter = 3),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  EmptyState(
                                    message: 'لا توجد أقساط ضمن هذا التصنيف',
                                    icon: Icons.filter_alt_outlined,
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final item = filtered[i];
                                  final color = _colorFor(item.status);
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: color.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Icon(
                                                  Icons.payments_outlined,
                                                  color: color,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item.name?.isNotEmpty == true
                                                      ? item.name!
                                                      : formatMoney(item.amount),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              StatusChip(
                                                label: installmentStatusLabel(item.status),
                                                color: color,
                                                compact: true,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _MiniStat(
                                                  label: 'المبلغ',
                                                  value: formatMoney(item.amount),
                                                ),
                                              ),
                                              Expanded(
                                                child: _MiniStat(
                                                  label: 'المدفوع',
                                                  value: formatMoney(item.paidAmount),
                                                ),
                                              ),
                                              Expanded(
                                                child: _MiniStat(
                                                  label: 'الاستحقاق',
                                                  value: formatDate(item.dueDate),
                                                ),
                                              ),
                                            ],
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
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: selected ? AppTheme.brandMid : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppTheme.brandMid : AppTheme.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.muted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
