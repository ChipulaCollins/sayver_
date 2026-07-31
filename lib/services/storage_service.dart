import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/savings_goal.dart';

class StorageService {
  static const String _goalsKey = 'sayver_savings_goals_v3';
  static const String _activeGoalIdKey = 'sayver_active_goal_id_v3';
  static const String _darkModeKey = 'sayver_dark_mode_v1';

  // In-memory fallback
  static List<SavingsGoal> _memoryGoals = [];
  static String? _memoryActiveId;
  static bool _memoryDarkMode = true;

  static Future<List<SavingsGoal>> loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_goalsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((item) => SavingsGoal.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('StorageService load error: $e. Falling back to memory storage.');
      }
    }

    return List.from(_memoryGoals);
  }

  static Future<void> saveGoals(List<SavingsGoal> goals) async {
    _memoryGoals = List.from(goals);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(goals.map((g) => g.toJson()).toList());
      await prefs.setString(_goalsKey, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('StorageService save error: $e');
      }
    }
  }

  static Future<String?> loadActiveGoalId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeGoalIdKey) ?? _memoryActiveId;
    } catch (_) {
      return _memoryActiveId;
    }
  }

  static Future<void> saveActiveGoalId(String goalId) async {
    _memoryActiveId = goalId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeGoalIdKey, goalId);
    } catch (_) {}
  }

  static Future<bool> loadDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? true;
    } catch (_) {
      return _memoryDarkMode;
    }
  }

  static Future<void> saveDarkMode(bool isDark) async {
    _memoryDarkMode = isDark;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDark);
    } catch (_) {}
  }
}
