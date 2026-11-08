import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../utils/labels.dart';
import '../widgets/info_row.dart';

class VisitorPassDetailScreen extends StatelessWidget {
  const VisitorPassDetailScreen({super.key, required this.pass});

  final VisitorPass pass;

  @override
  Widget build(BuildContext context) {
    final token = (pass.qrCodeToken ?? '').trim();
    final shareable = pass.isShareable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تصريح الزائر'),
        actions: [
          if (token.isNotEmpty)
            IconButton(
              tooltip: 'نسخ الرمز',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: token));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رمز التصريح')),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (!shareable)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
              ),
              child: Text(
                pass.isUsed
                    ? 'تم استخدام هذا التصريح ولن يُقبل عند البوابة مجدداً.'
                    : 'انتهت صلاحية هذا التصريح.',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                  height: 1.4,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Text(
                  pass.visitorName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                if ((pass.visitReason ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    pass.visitReason!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                if (token.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('لا يوجد رمز QR لهذا التصريح'),
                  )
                else
                  Opacity(
                    opacity: shareable ? 1 : 0.35,
                    child: QrImageView(
                      data: token,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppTheme.brand,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppTheme.brand,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  'صالح حتى ${formatDate(pass.validUntil)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            children: [
              InfoRow(
                label: 'الهاتف',
                value: (pass.phone ?? '').isEmpty ? '—' : pass.phone!,
                icon: Icons.phone_outlined,
              ),
              InfoRow(
                label: 'الحالة',
                value: pass.isUsed
                    ? 'مستخدم${pass.usedAt != null ? ' · ${formatDate(pass.usedAt)}' : ''}'
                    : pass.isExpired
                        ? 'منتهي'
                        : 'ساري',
                icon: Icons.verified_outlined,
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'اعرض هذا الرمز على شاشة الزائر عند البوابة. المسح يتم من لوحة الحراسة فقط.',
            style: TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w600,
              height: 1.45,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
