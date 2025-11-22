import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestResultStorage {
  static const String _keyTestResults = 'test_results';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Simpan hasil tes ke Firestore dan SharedPreferences
  static Future<void> saveTestResult({
    required String testTitle,
    required String status,
    required String iconName,
    required Map<String, dynamic> resultData,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('⚠️ User not logged in');
        return;
      }

      final userId = currentUser.uid;
      final now = DateTime.now();

      // Tentukan nama collection berdasarkan test title
      String collectionName = '';
      if (testTitle.contains('Body Mass Index') || testTitle.contains('BMI')) {
        collectionName = 'bmi_tests';
      } else if (testTitle.contains('Big Five') || testTitle.contains('OCEAN')) {
        collectionName = 'bigfive_tests';
      } else if (testTitle.contains('Burnout') || testTitle.contains('Kelelahan')) {
        collectionName = 'burnout_tests';
      }

      if (collectionName.isEmpty) {
        print('⚠️ Unknown test type: $testTitle');
        return;
      }

      // Simpan ke Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .add({
            'testTitle': testTitle,
            'status': status,
            'iconName': iconName,
            'resultData': resultData,
            'completedAt': Timestamp.fromDate(now),
            'createdAt': Timestamp.fromDate(now),
          });

      print('✅ Test result saved to Firestore: $testTitle');

      // Juga simpan ke SharedPreferences untuk cache lokal
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> results = await getTestResults();
      
      results.add({
        'testTitle': testTitle,
        'date': now.toIso8601String(),
        'status': status,
        'iconName': iconName,
        'resultData': resultData,
      });
      
      final jsonString = jsonEncode(results);
      await prefs.setString(_keyTestResults, jsonString);

    } catch (e) {
      print('❌ Error saving test result: $e');
    }
  }

  // Ambil semua hasil tes dari Firestore (sumber kebenaran)
  static Future<List<Map<String, dynamic>>> getTestResults() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return [];
    }

    try {
      List<Map<String, dynamic>> allResults = [];
      
      // Ambil data dari Firestore (source of truth)
      final bmiTests = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('bmi_tests')
          .orderBy('completedAt', descending: true)
          .get();

      for (var doc in bmiTests.docs) {
        final data = doc.data();
        allResults.add({
          'testTitle': data['testTitle'] ?? 'Tes Body Mass Index',
          'date': (data['completedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
          'status': data['status'] ?? 'Selesai',
          'iconName': data['iconName'] ?? 'monitor_weight_outlined',
          'resultData': data['resultData'] ?? {},
          'firestoreId': doc.id,
          'firestoreCollection': 'bmi_tests',
        });
      }

      final bigFiveTests = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('bigfive_tests')
          .orderBy('completedAt', descending: true)
          .get();

      for (var doc in bigFiveTests.docs) {
        final data = doc.data();
        allResults.add({
          'testTitle': data['testTitle'] ?? 'Tes Big Five Personality (OCEAN)',
          'date': (data['completedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
          'status': data['status'] ?? 'Selesai',
          'iconName': data['iconName'] ?? 'psychology_outlined',
          'resultData': data['resultData'] ?? {},
          'firestoreId': doc.id,
          'firestoreCollection': 'bigfive_tests',
        });
      }

      final burnoutTests = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('burnout_tests')
          .orderBy('completedAt', descending: true)
          .get();

      for (var doc in burnoutTests.docs) {
        final data = doc.data();
        allResults.add({
          'testTitle': data['testTitle'] ?? 'Tes Burnout (Kelelahan)',
          'date': (data['completedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
          'status': data['status'] ?? 'Selesai',
          'iconName': data['iconName'] ?? 'battery_alert_outlined',
          'resultData': data['resultData'] ?? {},
          'firestoreId': doc.id,
          'firestoreCollection': 'burnout_tests',
        });
      }

      // Cache to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(allResults);
      await prefs.setString(_keyTestResults, jsonString);

      return allResults;
    } catch (e) {
      print('Error loading from Firestore: $e');
      // Fallback to SharedPreferences cache
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
  }

  // Hapus hasil tes tertentu
  static Future<void> deleteTestResult(int index) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('⚠️ User not logged in');
        return;
      }

      List<Map<String, dynamic>> results = await getTestResults();
      
      if (index >= 0 && index < results.length) {
        final resultToDelete = results[index];
        final firestoreId = resultToDelete['firestoreId'];
        final firestoreCollection = resultToDelete['firestoreCollection'];

        // Hapus dari Firestore (source of truth)
        if (firestoreId != null && firestoreCollection != null) {
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection(firestoreCollection)
              .doc(firestoreId)
              .delete();
          print('✅ Test result deleted from Firestore');
        }

        // Hapus dari cache lokal
        results.removeAt(index);
        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(results);
        await prefs.setString(_keyTestResults, jsonString);
        print('✅ Test result removed from cache');
      }
    } catch (e) {
      print('❌ Error deleting test result: $e');
    }
  }

  // Hapus semua hasil tes
  static Future<void> clearAllResults() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('⚠️ User not logged in');
        return;
      }

      final userId = currentUser.uid;

      // Hapus semua BMI tests
      final bmiTests = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bmi_tests')
          .get();
      for (var doc in bmiTests.docs) {
        await doc.reference.delete();
      }
      print('✅ All BMI tests deleted from Firestore');

      // Hapus semua Big Five tests
      final bigFiveTests = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bigfive_tests')
          .get();
      for (var doc in bigFiveTests.docs) {
        await doc.reference.delete();
      }
      print('✅ All Big Five tests deleted from Firestore');

      // Hapus semua Burnout tests
      final burnoutTests = await _firestore
          .collection('users')
          .doc(userId)
          .collection('burnout_tests')
          .get();
      for (var doc in burnoutTests.docs) {
        await doc.reference.delete();
      }
      print('✅ All Burnout tests deleted from Firestore');

      // Hapus cache lokal
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyTestResults);
      print('✅ All test results cleared from cache');

    } catch (e) {
      print('❌ Error clearing all results: $e');
    }
  }
}
