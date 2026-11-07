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
