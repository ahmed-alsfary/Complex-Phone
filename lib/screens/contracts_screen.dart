import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  Color _statusColor(int? status) {
    switch (status) {
      case 2:
        return AppTheme.success;
      case 3:
        return AppTheme.info;
      case 4:
      case 5:
        return AppTheme.danger;
      default:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resident = context.watch<ResidentProvider>();
    final items = resident.contracts;

    return Scaffold(
      appBar: AppBar(title: Text('عقودي (${items.length})')),
      body: RefreshIndicator(
        color: AppTheme.brandMid,
        onRefresh: () =>
            context.read<ResidentProvider>().loadContracts(context.read<AuthProvider>()),
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
                      EmptyState(message: resident.error ?? 'لا توجد عقود'),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = items[i];
                      final color = _statusColor(c.contractStatus);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: AppTheme.brandSoft,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: AppTheme.brandMid,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.contractNumber?.isNotEmpty == true
                                              ? c.contractNumber!
                                              : 'عقد',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.5,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'تاريخ العقد: ${formatDate(c.contractDate)}',
                                          style: const TextStyle(
                                            color: AppTheme.muted,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(
                                    label: contractStatusLabel(c.contractStatus),
                                    color: color,
                                    compact: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _MoneyBlock(
                                        label: 'سعر البيع',
                                        value: formatMoney(c.sellingPrice),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 34,
                                      color: AppTheme.border,
                                    ),
                                    Expanded(
                                      child: _MoneyBlock(
                                        label: 'المتبقي',
                                        value: formatMoney(c.remainingAmount),
                                        emphasize: true,
                                      ),
                                    ),
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
    );
  }
}

class _MoneyBlock extends StatelessWidget {
  const _MoneyBlock({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: emphasize ? AppTheme.brandMid : AppTheme.text,
            ),
          ),
        ],
      ),
    );
  }
}
