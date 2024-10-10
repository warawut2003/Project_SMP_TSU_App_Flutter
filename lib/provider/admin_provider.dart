import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/models/auth_model.dart';

class AdminProvider extends ChangeNotifier {
  Admin? _admin;
  String? _accessToken;
  String? _refreshToken;

  Admin? get admin => _admin;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void onLogin(AdminModel adminModel) {
    _admin = adminModel.admin;
    _accessToken = adminModel.accessToken;
    _refreshToken = adminModel.refreshToken;
    notifyListeners();
  }

  void onLogout() {
    _admin = null;
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  void updateAccessToken(accessToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }
}
