import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../providers/settings_provider.dart';
import '../services/service_bill_service.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';

class ServicesBillsScreen extends StatefulWidget {
  const ServicesBillsScreen({super.key});

  @override
  State<ServicesBillsScreen> createState() => _ServicesBillsScreenState();
}

class _ServicesBillsScreenState extends State<ServicesBillsScreen> {
  bool _loading = true;
  String? _error;
  List<ServiceBillItem> _items = [];

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
      final page = await context.read<ServiceBillService>().getBills();
      if (!mounted) return;
      final items = [...page.items];
      items.sort((a, b) {
        final ay = a.year * 100 + a.month;
        final by = b.year * 100 + b.month;
        return by.compareTo(ay);
      });
      setState(() {
        _items = items;
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

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.servicesBills),
        actions: [
          IconButton(
            tooltip: s.refresh,
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
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
                        actionLabel: s.refresh,
                        onAction: _load,
                      ),
                    ],
                  )
                : _items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                          EmptyState(
                            message: s.noBills,
                            icon: Icons.bolt_outlined,
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final bill = _items[i];
                          final hasReading = bill.reading > 0 || bill.previousReading > 0 || bill.consumption > 0;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bill.serviceDisplayName?.trim().isNotEmpty == true
                                              ? bill.serviceDisplayName!
                                              : s.servicesBills,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      StatusChip(
                                        label: bill.paid ? s.paid : s.unpaid,
                                        color: bill.paid ? AppTheme.success : AppTheme.warning,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${bill.month.toString().padLeft(2, '0')}/${bill.year}'
                                    '${(bill.unitNumber ?? '').isNotEmpty ? ' · ${bill.unitNumber}' : ''}',
                                    style: const TextStyle(
                                      color: AppTheme.muted,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  if (hasReading) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      s.readings,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 6,
                                      children: [
                                        _kv(s.previousReading, bill.previousReading.toStringAsFixed(0)),
                                        _kv(s.currentReading, bill.reading.toStringAsFixed(0)),
                                        _kv(
                                          s.consumption,
                                          '${bill.consumption.toStringAsFixed(0)}${(bill.unitOfMeasure ?? '').isNotEmpty ? ' ${bill.unitOfMeasure}' : ''}',
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        s.amount,
                                        style: const TextStyle(
                                          color: AppTheme.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatMoney(bill.netAmount > 0 ? bill.netAmount : bill.amount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: AppTheme.brandMid,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (bill.dueDate != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDate(bill.dueDate),
                                      style: const TextStyle(
                                        color: AppTheme.muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
      ],
    );
  }
}
