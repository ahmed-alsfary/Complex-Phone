import '../config/app_config.dart';
import '../core/api_client.dart';
import '../models/models.dart';

class ComplexAdService {
  ComplexAdService(this._api);

  final ApiClient _api;

  Future<List<ComplexAd>> getActive({String? complexId}) {
    return _api.get(
      '/api/ComplexAds/active',
      query: {
        'complexId': complexId ?? AppConfig.complexId,
      },
      attachComplexId: false,
      map: (data) {
        if (data is! List) return <ComplexAd>[];
        return data
            .whereType<Map>()
            .map((e) => ComplexAd.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }
}
