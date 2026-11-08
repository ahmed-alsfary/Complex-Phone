import '../core/api_client.dart';
import '../models/models.dart';

class VisitorService {
  VisitorService(this._api);

  final ApiClient _api;

  Future<PagedResult<VisitorPass>> list({int page = 1, int pageSize = 50}) {
    return _api.get(
      '/api/Visitors',
      query: {'Page': page, 'PageSize': pageSize},
      attachComplexId: false,
      map: (data) => PagedResult.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : null,
        VisitorPass.fromJson,
      ),
    );
  }

  Future<VisitorPass> create({
    required String visitorName,
    String? visitorPhone,
    String? visitReason,
    DateTime? validUntil,
    String? unitId,
  }) {
    return _api.post(
      '/api/Visitors',
      data: {
        'visitorName': visitorName.trim(),
        if (visitorPhone != null && visitorPhone.trim().isNotEmpty)
          'visitorPhone': visitorPhone.trim(),
        if (visitReason != null && visitReason.trim().isNotEmpty)
          'visitReason': visitReason.trim(),
        if (validUntil != null) 'validUntil': validUntil.toIso8601String(),
        if (unitId != null && unitId.isNotEmpty) 'unitId': unitId,
      },
      map: (data) => VisitorPass.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }
}
