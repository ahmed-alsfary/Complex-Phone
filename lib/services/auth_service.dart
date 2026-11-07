import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../core/api_client.dart';
import '../models/models.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<UserInfo> login(String phone, String code) async {
    final bundle = await _api.post(
      '/api/Auth/resident-login',
      data: {
        'phone': phone.trim(),
        'code': code.trim(),
      },
      map: (data) {
        final map = Map<String, dynamic>.from(data as Map? ?? {});
        final token = map['token'] as String?;
        if (token == null || token.isEmpty) {
          throw ApiException('لم يتم استلام رمز الدخول');
        }
        final userRaw = map['user'];
        final userJson = userRaw is Map
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{};
        if (userJson['phone'] == null) userJson['phone'] = phone.trim();
        return _LoginBundle(token: token, user: UserInfo.fromJson(userJson));
      },
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, bundle.token);
    await prefs.setString(AppConfig.userKey, jsonEncode(bundle.user.toJson()));

    // تحديث بيانات المستخدم من /me بعد حفظ التوكن
    try {
      final me = await getMe();
      await prefs.setString(AppConfig.userKey, jsonEncode(me.toJson()));
      return me;
    } catch (_) {
      return bundle.user;
    }
  }

  Future<UserInfo> getMe() {
    return _api.get(
      '/api/Auth/me',
      attachComplexId: false,
      map: (data) => UserInfo.fromJson(Map<String, dynamic>.from(data as Map? ?? {})),
    );
  }

  Future<UserInfo?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    final raw = prefs.getString(AppConfig.userKey);
    if (token == null || token.isEmpty || raw == null) return null;
    try {
      final cached = UserInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      try {
        final me = await getMe();
        await prefs.setString(AppConfig.userKey, jsonEncode(me.toJson()));
        return me;
      } catch (_) {
        return cached;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
  }
}

class _LoginBundle {
  _LoginBundle({required this.token, required this.user});
  final String token;
  final UserInfo user;
}
