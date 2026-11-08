import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class ResidentService {
  ResidentService(this._api);

  final ApiClient _api;

  Future<ResidentProfile> getProfile(String residentId) {
    return _api.get(
      '/api/Residents/$residentId/profile',
      attachComplexId: false,
      map: (data) => ResidentProfile.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<ResidentProfile> updateSelfProfile({
    required String residentId,
    DateTime? birthDate,
    String? nickname,
    String? secondaryPhone,
    String? email,
    String? loginCode,
  }) {
    return _api.put(
      '/api/Residents/$residentId/self-profile',
      data: {
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
        'nickname': nickname,
        'secondaryPhone': secondaryPhone,
        'email': email,
        if (loginCode != null && loginCode.trim().isNotEmpty) 'loginCode': loginCode.trim(),
      },
      map: (data) => ResidentProfile.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<ResidentProfile> updateHousehold({
    required String residentId,
    required int maleCount,
    required int femaleCount,
  }) {
    return _api.put(
      '/api/Residents/$residentId/household',
      data: {
        'maleCount': maleCount,
        'femaleCount': femaleCount,
      },
      map: (data) => ResidentProfile.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<FamilyMember> addFamilyMember({
    required String residentId,
    required String fullName,
    required int relation,
    String? nationalId,
    DateTime? birthDate,
  }) {
    return _api.post(
      '/api/Residents/$residentId/family-members',
      data: {
        'fullName': fullName.trim(),
        'relation': relation,
        'nationalId': nationalId?.trim(),
        'birthDate': birthDate?.toIso8601String(),
      },
      map: (data) => FamilyMember.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<FamilyMember> updateFamilyMember({
    required String residentId,
    required String memberId,
    required String fullName,
    required int relation,
    String? nationalId,
    DateTime? birthDate,
  }) {
    return _api.put(
      '/api/Residents/$residentId/family-members/$memberId',
      data: {
        'fullName': fullName.trim(),
        'relation': relation,
        'nationalId': nationalId?.trim(),
        'birthDate': birthDate?.toIso8601String(),
      },
      map: (data) => FamilyMember.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<bool> deleteFamilyMember({
    required String residentId,
    required String memberId,
  }) {
    return _api.delete(
      '/api/Residents/$residentId/family-members/$memberId',
      map: (_) => true,
    );
  }

  /// يبطل رمز الدخول على السيرفر (لا يحذف السجل).
  Future<bool> selfDelete(String residentId) {
    return _api.post(
      '/api/Residents/$residentId/self-delete',
      data: {},
      map: (_) => true,
    );
  }

  Future<String> uploadProfilePhoto({
    required String residentId,
    required String filePath,
    required String fileName,
  }) {
    return _api.postMultipart(
      '/api/Residents/$residentId/profile-photo',
      data: FormData.fromMap({
        'file': MultipartFile.fromFileSync(filePath, filename: fileName),
      }),
      map: (data) {
        if (data is Map && data['profilePhotoUrl'] != null) {
          return '${data['profilePhotoUrl']}';
        }
        return '';
      },
    );
  }

  Future<UnitItem> getUnit(String unitId) {
    return _api.get(
      '/api/Units/$unitId',
      attachComplexId: false,
      map: (data) => UnitItem.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<PagedResult<SalesContractItem>> getContracts({
    required String customerId,
    String? unitId,
    int page = 1,
    int pageSize = 50,
  }) {
    return _api.get(
      '/api/SalesContracts',
      query: {
        'CustomerId': customerId,
        if (unitId != null && unitId.isNotEmpty) 'UnitId': unitId,
        'Page': page,
        'PageSize': pageSize,
      },
      attachComplexId: false,
      map: (data) => PagedResult.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : null,
        SalesContractItem.fromJson,
      ),
    );
  }

  Future<PagedResult<InstallmentItem>> getInstallments({
    required String customerId,
    String? unitId,
    String? contractId,
    int page = 1,
    int pageSize = 200,
  }) {
    return _api.get(
      '/api/Installments',
      query: {
        'CustomerId': customerId,
        if (unitId != null && unitId.isNotEmpty) 'UnitId': unitId,
        if (contractId != null && contractId.isNotEmpty) 'ContractId': contractId,
        'Page': page,
        'PageSize': pageSize,
      },
      attachComplexId: false,
      map: (data) => PagedResult.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : null,
        InstallmentItem.fromJson,
      ),
    );
  }

  Future<PagedResult<PaymentItem>> getPayments({
    required String customerId,
    int page = 1,
    int pageSize = 100,
  }) {
    return _api.get(
      '/api/Payments',
      query: {
        'CustomerId': customerId,
        'Page': page,
        'PageSize': pageSize,
      },
      attachComplexId: false,
      map: (data) => PagedResult.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : null,
        PaymentItem.fromJson,
      ),
    );
  }
}
