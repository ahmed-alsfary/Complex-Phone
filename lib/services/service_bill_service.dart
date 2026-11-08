import '../core/api_client.dart';
import '../models/models.dart';

class ServiceBillService {
  ServiceBillService(this._api);

  final ApiClient _api;

  Future<PagedResult<ServiceBillItem>> getBills({
    int page = 1,
    int pageSize = 100,
  }) {
    return _api.get(
      '/api/ServiceBills',
      query: {'Page': page, 'PageSize': pageSize},
      attachComplexId: false,
      map: (data) => PagedResult.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : null,
        ServiceBillItem.fromJson,
      ),
    );
  }
}
