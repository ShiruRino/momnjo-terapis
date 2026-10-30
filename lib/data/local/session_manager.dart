import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_profile';
  static const String _keyDutyStatus = 'duty_status';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveSession({
    required String token,
    required UserProfile user,
    DutyStatus? dutyStatus,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    if (dutyStatus != null) {
      await prefs.setString(_keyDutyStatus, dutyStatus.name);
    }
  }

  static Future<String?> getToken() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<UserProfile?> getUser() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        return UserProfile.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<DutyStatus?> getDutyStatus() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final status = prefs.getString(_keyDutyStatus);
    if (status == DutyStatus.onDuty.name) return DutyStatus.onDuty;
    if (status == DutyStatus.offDuty.name) return DutyStatus.offDuty;
    return null;
  }

  static Future<void> saveDutyStatus(DutyStatus status) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyDutyStatus, status.name);
  }

  static Future<void> clearSession() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyDutyStatus);
  }
}

