import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script untuk fix admin document yang hilang
class FixAdminDocument {
  static Future<void> ensureAdminDocumentExists() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    const adminEmail = 'admin@gmail.com';
    
    try {
      // Find user in Auth by email (tidak bisa query langsung, jadi kita cek di Firestore dulu)
      final usersSnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();
      
      if (usersSnapshot.docs.isEmpty) {
        print('⚠️ Admin document not found in Firestore');
        
        // Check if admin exists in Firebase Auth
        // We need to get all users and find the admin (or use admin SDK)
        // For now, we'll create the document when admin logs in
        print('Admin document will be created on first login');
      } else {
        print('✅ Admin document exists in Firestore');
        final doc = usersSnapshot.docs.first;
        print('Admin UID: ${doc.id}');
        print('Admin Role: ${doc.data()['role']}');
      }
    } catch (e) {
      print('❌ Error checking admin document: $e');
    }
  }
  
  /// Create admin document for currently logged in user
  static Future<void> createAdminDocumentForCurrentUser() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;
    
    if (user == null) {
      print('❌ No user logged in');
      return;
    }
    
    if (user.email != 'admin@gmail.com') {
      print('❌ Current user is not admin');
      return;
    }
    
    try {
      // Check if document already exists
      final doc = await firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        print('✅ Admin document already exists');
        // Make sure role is admin
        if (doc.data()?['role'] != 'admin') {
          await doc.reference.update({'role': 'admin'});
          print('✅ Updated role to admin');
        }
      } else {
        // Create new document
        await firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': user.email,
          'name': 'Administrator',
          'role': 'admin',
          'department': 'IT',
          'employeeId': 'ADMIN001',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print('✅ Admin document created successfully');
      }
    } catch (e) {
      print('❌ Error creating admin document: $e');
    }
  }
}
