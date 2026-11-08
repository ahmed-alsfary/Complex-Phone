import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../providers/settings_provider.dart';
import '../services/vehicle_service.dart';
import '../utils/labels.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, this.vehicle});

  final VehicleItem? vehicle;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateCtrl = TextEditingController();
  final _manufacturerCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _type = 1;
  bool _saving = false;

  bool get _editing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _plateCtrl.text = v.plateNumber;
      _manufacturerCtrl.text = v.manufacturer ?? '';
      _yearCtrl.text = v.year?.toString() ?? '';
      _colorCtrl.text = v.color ?? '';
      _notesCtrl.text = v.notes ?? '';
      _type = v.vehicleType;
    }
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _manufacturerCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final residentId = context.read<ResidentProvider>().profile?.id ??
        context.read<AuthProvider>().user?.residentId;
    if (residentId == null || residentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديد هوية الساكن')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final yearText = _yearCtrl.text.trim();
      final year = yearText.isEmpty ? null : int.tryParse(yearText);
      final service = context.read<VehicleService>();
      if (_editing) {
        await service.update(
          id: widget.vehicle!.id,
          residentId: residentId,
          plateNumber: _plateCtrl.text,
          vehicleType: _type,
          manufacturer: _manufacturerCtrl.text,
          color: _colorCtrl.text,
          year: year,
          notes: _notesCtrl.text,
        );
      } else {
        await service.create(
          residentId: residentId,
          plateNumber: _plateCtrl.text,
          vehicleType: _type,
          manufacturer: _manufacturerCtrl.text,
          color: _colorCtrl.text,
          year: year,
          notes: _notesCtrl.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
    final s = context.watch<SettingsProvider>().s;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? s.editVehicle : s.addVehicle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            TextFormField(
              controller: _plateCtrl,
              decoration: InputDecoration(labelText: s.plateNumber),
              textDirection: TextDirection.ltr,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _type,
              decoration: InputDecoration(labelText: s.vehicleType),
              items: vehicleTypeOptions
                  .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? 1),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _manufacturerCtrl,
              decoration: InputDecoration(labelText: '${s.manufacturer} *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _yearCtrl,
              decoration: InputDecoration(labelText: s.manufactureYear),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final y = int.tryParse(v.trim());
                if (y == null || y < 1970 || y > DateTime.now().year + 1) {
                  return 'سنة غير صالحة';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _colorCtrl,
              decoration: InputDecoration(labelText: s.color),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(labelText: s.notes),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(s.save),
            ),
          ],
        ),
      ),
    );
  }
}
