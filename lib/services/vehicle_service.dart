import '../core/api_client.dart';
import '../models/models.dart';

class VehicleService {
  VehicleService(this._api);

  final ApiClient _api;

  Future<PagedResult<VehicleItem>> list({int page = 1, int pageSize = 50}) {
    return _api.get(
      '/api/Vehicles',
      query: {'Page': page, 'PageSize': pageSize},
      attachComplexId: false,
      map: (data) => PagedResult.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : null,
        VehicleItem.fromJson,
      ),
    );
  }

  Future<VehicleItem> create({
    required String residentId,
    required String plateNumber,
    required int vehicleType,
    required String manufacturer,
    String? color,
    int? year,
    String? notes,
    String? parkingNumber,
  }) {
    return _api.post(
      '/api/Vehicles',
      data: {
        'residentId': residentId,
        'plateNumber': plateNumber.trim(),
        'vehicleType': vehicleType,
        'manufacturer': manufacturer.trim(),
        'color': (color ?? '').trim(),
        'year': year,
        'notes': notes?.trim(),
        'parkingNumber': parkingNumber?.trim(),
        'model': null,
      },
      map: (data) => VehicleItem.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<VehicleItem> update({
    required String id,
    required String residentId,
    required String plateNumber,
    required int vehicleType,
    required String manufacturer,
    String? color,
    int? year,
    String? notes,
    String? parkingNumber,
  }) {
    return _api.put(
      '/api/Vehicles/$id',
      data: {
        'residentId': residentId,
        'plateNumber': plateNumber.trim(),
        'vehicleType': vehicleType,
        'manufacturer': manufacturer.trim(),
        'color': (color ?? '').trim(),
        'year': year,
        'notes': notes?.trim(),
        'parkingNumber': parkingNumber?.trim(),
        'model': null,
      },
      map: (data) => VehicleItem.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<bool> delete(String id) {
    return _api.delete(
      '/api/Vehicles/$id',
      map: (_) => true,
    );
  }
}
