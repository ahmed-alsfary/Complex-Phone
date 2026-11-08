import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/resident_provider.dart';
import '../services/visitor_service.dart';

class CreateVisitorPassScreen extends StatefulWidget {
  const CreateVisitorPassScreen({super.key});

  @override
  State<CreateVisitorPassScreen> createState() => _CreateVisitorPassScreenState();
}

class _CreateVisitorPassScreenState extends State<CreateVisitorPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController(text: 'زيارة عائلية');
  DateTime _validUntil = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    23,
    59,
    59,
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _validUntil,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('ar'),
    );
    if (date == null) return;
    setState(() {
      _validUntil = DateTime(date.year, date.month, date.day, 23, 59, 59);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final unitId = context.read<ResidentProvider>().profile?.unitId;
      final pass = await context.read<VisitorService>().create(
            visitorName: _nameCtrl.text,
            visitorPhone: _phoneCtrl.text,
            visitReason: _reasonCtrl.text,
            validUntil: _validUntil,
            unitId: unitId,
          );
      if (!mounted) return;
      Navigator.of(context).pop(pass);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصريح زائر جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            const Text(
              'سيُنشأ رمز QR يعرضه الزائر عند البوابة ليتم مسحه من لوحة الحراسة.',
              style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600, height: 1.45),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'اسم الزائر',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل اسم الزائر' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'هاتف الزائر',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonCtrl,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'سبب الزيارة',
                prefixIcon: Icon(Icons.info_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'صالح حتى',
                    prefixIcon: Icon(Icons.event_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_validUntil.year}-${_validUntil.month.toString().padLeft(2, '0')}-${_validUntil.day.toString().padLeft(2, '0')} 23:59',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('إنشاء التصريح'),
            ),
          ],
        ),
      ),
    );
  }
}
