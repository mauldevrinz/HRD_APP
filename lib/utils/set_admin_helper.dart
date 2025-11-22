import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Helper untuk set user sebagai admin
/// Panggil ini sekali saja untuk set admin pertama kali
class SetAdminHelper {
  static Future<bool> setUserAsAdmin(String email) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Find user by email
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('User not found with email: $email');
        return false;
      }

      final userDoc = querySnapshot.docs.first;
      await userDoc.reference.update({'role': 'admin'});

      print('✅ User $email is now an admin!');
      return true;
    } catch (e) {
      print('❌ Error setting admin: $e');
      return false;
    }
  }

  /// Set current logged in user as admin
  static Future<bool> setCurrentUserAsAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return false;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'role': 'admin'});

      print('✅ Current user is now an admin!');
      return true;
    } catch (e) {
      print('❌ Error setting admin: $e');
      return false;
    }
  }
}
