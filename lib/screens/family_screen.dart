import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../providers/settings_provider.dart';
import '../services/resident_service.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _maleCtrl = TextEditingController();
  final _femaleCtrl = TextEditingController();
  bool _savingCounts = false;
  bool _busyMember = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ResidentProvider>().profile;
      _syncCounts(profile);
      if (profile == null) {
        context.read<ResidentProvider>().loadProfile(context.read<AuthProvider>());
      }
    });
  }

  void _syncCounts(ResidentProfile? profile) {
    _maleCtrl.text = '${profile?.maleCount ?? 0}';
    _femaleCtrl.text = '${profile?.femaleCount ?? 0}';
  }

  @override
  void dispose() {
    _maleCtrl.dispose();
    _femaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<ResidentProvider>().loadProfile(context.read<AuthProvider>());
    if (!mounted) return;
    _syncCounts(context.read<ResidentProvider>().profile);
  }

  Future<void> _saveCounts() async {
    final profile = context.read<ResidentProvider>().profile;
    if (profile == null) return;
    final male = int.tryParse(_maleCtrl.text.trim()) ?? 0;
    final female = int.tryParse(_femaleCtrl.text.trim()) ?? 0;
    setState(() => _savingCounts = true);
    try {
      final updated = await context.read<ResidentService>().updateHousehold(
            residentId: profile.id,
            maleCount: male,
            femaleCount: female,
          );
      context.read<ResidentProvider>().applyProfile(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الأعداد')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _savingCounts = false);
    }
  }

  Future<void> _openMemberForm({FamilyMember? member}) async {
    final profile = context.read<ResidentProvider>().profile;
    if (profile == null) return;

    final fullNameCtrl = TextEditingController(text: member?.fullName ?? '');
    final nationalIdCtrl = TextEditingController(text: member?.nationalId ?? '');
    var relation = member?.relation ?? 4;
    var birthDate = member?.birthDate;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final s = context.read<SettingsProvider>().s;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.viewInsetsOf(ctx).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    member == null ? s.addFamilyMember : s.editFamilyMember,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: fullNameCtrl,
                    decoration: InputDecoration(labelText: s.fullName),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: relation,
                    decoration: InputDecoration(labelText: s.relation),
                    items: familyRelationOptions
                        .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label)))
                        .toList(),
                    onChanged: (v) => setModal(() => relation = v ?? 5),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nationalIdCtrl,
                    decoration: InputDecoration(labelText: s.nationalId),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.birthDate),
                    subtitle: Text(formatDate(birthDate)),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: birthDate ?? DateTime(2000, 1, 1),
                        firstDate: DateTime(1940),
                        lastDate: DateTime.now(),
                        locale: const Locale('ar'),
                      );
                      if (picked != null) setModal(() => birthDate = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      if (fullNameCtrl.text.trim().isEmpty) return;
                      Navigator.pop(ctx, true);
                    },
                    child: Text(s.save),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    final name = fullNameCtrl.text.trim();
    final nationalId = nationalIdCtrl.text.trim();
    fullNameCtrl.dispose();
    nationalIdCtrl.dispose();
    if (saved != true || name.isEmpty || !mounted) return;

    setState(() => _busyMember = true);
    try {
      final service = context.read<ResidentService>();
      if (member?.id == null) {
        await service.addFamilyMember(
          residentId: profile.id,
          fullName: name,
          relation: relation,
          nationalId: nationalId.isEmpty ? null : nationalId,
          birthDate: birthDate,
        );
      } else {
        await service.updateFamilyMember(
          residentId: profile.id,
          memberId: member!.id!,
          fullName: name,
          relation: relation,
          nationalId: nationalId.isEmpty ? null : nationalId,
          birthDate: birthDate,
        );
      }
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _busyMember = false);
    }
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final profile = context.read<ResidentProvider>().profile;
    if (profile == null || member.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف فرد'),
        content: Text('حذف ${member.fullName}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busyMember = true);
    try {
      await context.read<ResidentService>().deleteFamilyMember(
            residentId: profile.id,
            memberId: member.id!,
          );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _busyMember = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().s;
    final resident = context.watch<ResidentProvider>();
    final profile = resident.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.family),
        actions: [
          IconButton(
            tooltip: s.refresh,
            onPressed: resident.loading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busyMember ? null : () => _openMemberForm(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(s.addFamilyMember),
      ),
      body: RefreshIndicator(
        color: AppTheme.brandMid,
        onRefresh: _refresh,
        child: profile == null && resident.loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : profile == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                      EmptyState(
                        message: resident.error ?? 'تعذر تحميل البيانات',
                        actionLabel: s.refresh,
                        onAction: _refresh,
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    children: [
                      SectionHeader(title: s.householdCounts),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _maleCtrl,
                                      decoration: InputDecoration(labelText: s.maleCount),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _femaleCtrl,
                                      decoration: InputDecoration(labelText: s.femaleCount),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: FilledButton(
                                  onPressed: _savingCounts ? null : _saveCounts,
                                  child: _savingCounts
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(s.updateInfo),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SectionHeader(title: '${s.familyMembers} (${profile.familyMembers.length})'),
                      if (profile.familyMembers.isEmpty)
                        Card(
                          child: EmptyState(message: s.noFamilyMembers, icon: Icons.groups_outlined),
                        )
                      else
                        ...profile.familyMembers.map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                onTap: _busyMember ? null : () => _openMemberForm(member: m),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.brandSoft,
                                    child: Text(
                                    m.fullName.isNotEmpty ? m.fullName.substring(0, 1) : '؟',
                                    style: const TextStyle(
                                      color: AppTheme.brandMid,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                title: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text(
                                  [
                                    familyRelationLabel(m.relation),
                                    if ((m.nationalId ?? '').isNotEmpty) m.nationalId!,
                                    if (m.birthDate != null) formatDate(m.birthDate),
                                  ].join(' · '),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                                ),
                                trailing: IconButton(
                                  onPressed: _busyMember ? null : () => _deleteMember(m),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
