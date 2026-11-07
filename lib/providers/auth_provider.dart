import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  UserInfo? user;
  bool bootstrapping = true;
  bool loading = false;
  String? error;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    bootstrapping = true;
    notifyListeners();
    user = await _authService.restoreSession();
    bootstrapping = false;
    notifyListeners();
  }

  Future<bool> login(String phone, String code) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.login(phone, code);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }
}
