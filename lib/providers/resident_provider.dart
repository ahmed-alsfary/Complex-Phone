import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/resident_service.dart';

enum ResidentTab { home, unit, installments, contracts, profile }

class ResidentProvider extends ChangeNotifier {
  ResidentProvider(this._service);

  final ResidentService _service;

  bool loading = false;
  String? error;
  ResidentProfile? profile;
  UnitItem? unit;
  List<SalesContractItem> contracts = [];
  List<InstallmentItem> installments = [];
  List<PaymentItem> payments = [];

  int _requestId = 0;

  Future<void> loadTab(AuthProvider auth, ResidentTab tab) {
    switch (tab) {
      case ResidentTab.home:
        return loadHome(auth);
      case ResidentTab.unit:
        return loadUnit(auth);
      case ResidentTab.installments:
        return loadInstallments(auth);
      case ResidentTab.contracts:
        return loadContracts(auth);
      case ResidentTab.profile:
        return loadProfile(auth);
    }
  }

  /// توافق مع السحب للتحديث الشامل إن لزم
  Future<void> load(AuthProvider auth) => loadHome(auth);

  Future<void> loadHome(AuthProvider auth) {
    return _run(auth, () async {
      final ctx = await _fetchProfile(auth);
      await Future.wait([
        _fetchUnit(ctx.unitId),
        _fetchContracts(ctx),
        _fetchInstallments(ctx),
      ]);
    });
  }

  Future<void> loadUnit(AuthProvider auth) {
    return _run(auth, () async {
      final ctx = await _fetchProfile(auth);
      await _fetchUnit(ctx.unitId);
    });
  }

  Future<void> loadInstallments(AuthProvider auth) {
    return _run(auth, () async {
      final ctx = await _fetchProfile(auth);
      await _fetchInstallments(ctx);
    });
  }

  Future<void> loadContracts(AuthProvider auth) {
    return _run(auth, () async {
      final ctx = await _fetchProfile(auth);
      await _fetchContracts(ctx);
    });
  }

  Future<void> loadProfile(AuthProvider auth) {
    return _run(auth, () async {
      final ctx = await _fetchProfile(auth);
      await _fetchPayments(ctx.customerId);
    });
  }

  Future<void> _run(AuthProvider auth, Future<void> Function() action) async {
    if (auth.user == null) return;

    final requestId = ++_requestId;
    loading = true;
    error = null;
    notifyListeners();

    try {
      await action();
      if (requestId != _requestId) return;
      loading = false;
      notifyListeners();
    } catch (e) {
      if (requestId != _requestId) return;
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
      notifyListeners();
    }
  }

  Future<_ResidentContext> _fetchProfile(AuthProvider auth) async {
    final user = auth.user;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final residentId = user.residentId;
    if (residentId == null || residentId.isEmpty) {
      throw Exception('حساب الساكن لا يحتوي على residentId');
    }

    profile = await _service.getProfile(residentId);

    final customerId = (user.customerId != null && user.customerId!.isNotEmpty)
        ? user.customerId!
        : profile!.customerId;

    return _ResidentContext(
      customerId: customerId,
      unitId: profile!.unitId,
    );
  }

  Future<void> _fetchUnit(String unitId) async {
    try {
      if (unitId.isNotEmpty) {
        unit = await _service.getUnit(unitId);
      } else {
        unit = null;
      }
    } catch (_) {
      unit = null;
    }
  }

  Future<void> _fetchContracts(_ResidentContext ctx) async {
    try {
      final page = await _service.getContracts(
        customerId: ctx.customerId,
        unitId: ctx.unitId,
      );
      contracts = page.items;
    } catch (_) {
      contracts = [];
    }
  }

  Future<void> _fetchInstallments(_ResidentContext ctx) async {
    try {
      final page = await _service.getInstallments(
        customerId: ctx.customerId,
        unitId: ctx.unitId,
      );
      final items = [...page.items];
      items.sort((a, b) {
        final ad = a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ad.compareTo(bd);
      });
      installments = items;
    } catch (_) {
      installments = [];
    }
  }

  Future<void> _fetchPayments(String customerId) async {
    try {
      final page = await _service.getPayments(customerId: customerId);
      payments = page.items;
    } catch (_) {
      payments = [];
    }
  }

  void applyProfile(ResidentProfile updated) {
    profile = updated;
    notifyListeners();
  }

  void clear() {
    _requestId++;
    profile = null;
    unit = null;
    contracts = [];
    installments = [];
    payments = [];
    error = null;
    loading = false;
    notifyListeners();
  }
}

class _ResidentContext {
  const _ResidentContext({
    required this.customerId,
    required this.unitId,
  });

  final String customerId;
  final String unitId;
}
