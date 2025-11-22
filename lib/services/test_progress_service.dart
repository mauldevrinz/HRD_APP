import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TestProgressService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save BMI test result
  Future<bool> saveBMIResult({
    required double weight,
    required double height,
    required double bmi,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final data = {
        'userId': user.uid,
        'weight': weight,
        'height': height,
        'bmi': bmi,
        'category': category,
        'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bmi_tests')
          .add(data);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_bmi', jsonEncode({
        'weight': weight,
        'height': height,
        'bmi': bmi,
        'category': category,
        'date': DateTime.now().toIso8601String(),
      }));

      return true;
    } catch (e) {
      return false;
    }
  }

  // Save Big Five test result
  Future<bool> saveBigFiveResult(Map<String, dynamic> scores) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final data = {
        'userId': user.uid,
        'scores': scores,
        'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bigfive_tests')
          .add(data);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_bigfive', jsonEncode({
        'scores': scores,
        'date': DateTime.now().toIso8601String(),
      }));

      return true;
    } catch (e) {
      return false;
    }
  }

  // Save Burnout test result
  Future<bool> saveBurnoutResult({
    required int totalScore,
    required String category,
    required Map<String, int> dimensionScores,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final data = {
        'userId': user.uid,
        'totalScore': totalScore,
        'category': category,
        'dimensionScores': dimensionScores,
        'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('burnout_tests')
          .add(data);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_burnout', jsonEncode({
        'totalScore': totalScore,
        'category': category,
        'dimensionScores': dimensionScores,
        'date': DateTime.now().toIso8601String(),
      }));

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get last BMI result
  Future<Map<String, dynamic>?> getLastBMIResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('last_bmi');
      if (data != null) {
        return jsonDecode(data);
      }

      // Try from Firestore if not in local storage
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('bmi_tests')
            .orderBy('completedAt', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.data();
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Get last Big Five result
  Future<Map<String, dynamic>?> getLastBigFiveResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('last_bigfive');
      if (data != null) {
        return jsonDecode(data);
      }

      // Try from Firestore if not in local storage
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('bigfive_tests')
            .orderBy('completedAt', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.data();
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Get last Burnout result
  Future<Map<String, dynamic>?> getLastBurnoutResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('last_burnout');
      if (data != null) {
        return jsonDecode(data);
      }

      // Try from Firestore if not in local storage
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('burnout_tests')
            .orderBy('completedAt', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.data();
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Get all test history
  Future<List<Map<String, dynamic>>> getTestHistory(String testType) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('${testType}_tests')
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }
}
