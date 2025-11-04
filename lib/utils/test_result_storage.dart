import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TestResultStorage {
  static const String _keyTestResults = 'test_results';

  // Simpan hasil tes
  static Future<void> saveTestResult({
    required String testTitle,
    required String status,
    required String iconName,
    required Map<String, dynamic> resultData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data yang sudah ada
    List<Map<String, dynamic>> results = await getTestResults();
    
    // Tambah hasil tes baru
    results.add({
      'testTitle': testTitle,
      'date': DateTime.now().toIso8601String(),
      'status': status,
      'iconName': iconName,
      'resultData': resultData,
    });
    
    // Simpan ke SharedPreferences
    final jsonString = jsonEncode(results);
    await prefs.setString(_keyTestResults, jsonString);
  }

  // Ambil semua hasil tes
  static Future<List<Map<String, dynamic>>> getTestResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTestResults);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Hapus hasil tes tertentu
  static Future<void> deleteTestResult(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> results = await getTestResults();
    
    if (index >= 0 && index < results.length) {
      results.removeAt(index);
      final jsonString = jsonEncode(results);
      await prefs.setString(_keyTestResults, jsonString);
    }
  }

  // Hapus semua hasil tes
  static Future<void> clearAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTestResults);
  }
}
