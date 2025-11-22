import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script untuk membuat akun admin default
/// Email: admin@gmail.com
/// Password: admin123
class CreateAdmin {
  static Future<void> createDefaultAdmin() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    const adminEmail = 'admin@gmail.com';
    const adminPassword = 'admin123';
    const adminName = 'Administrator';
    
    try {
      // Check if admin already exists
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        print('✅ Admin account already exists: $adminEmail');
        
        // Update role to admin if not already
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        if (data['role'] != 'admin') {
          await doc.reference.update({'role': 'admin'});
          print('✅ Updated existing user to admin role');
        }
        return;
      }
      
      // Check if admin already exists in Firestore (by email)
      final existingDocs = await firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();
      
      if (existingDocs.docs.isNotEmpty) {
        print('✅ Admin account already exists in Firestore');
        // Make sure admin has correct role
        final doc = existingDocs.docs.first;
        if (doc.data()['role'] != 'admin') {
          await doc.reference.update({'role': 'admin'});
          print('✅ Updated user role to admin');
        }
        // Make sure user is logged out
        await auth.signOut();
        return;
      }
      
      // Create admin account
      try {
        print('📝 Creating admin account...');
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        
        if (userCredential.user != null) {
          print('✅ Admin user created in Firebase Auth');
          
          // Create user document in Firestore with retry
          int retries = 3;
          bool success = false;
          
          while (retries > 0 && !success) {
            try {
              await firestore.collection('users').doc(userCredential.user!.uid).set({
                'userId': userCredential.user!.uid,
                'email': adminEmail,
                'name': adminName,
                'role': 'admin',
                'department': 'IT',
                'employeeId': 'ADMIN001',
                'photoUrl': '',
                'createdAt': FieldValue.serverTimestamp(),
                'lastLogin': FieldValue.serverTimestamp(),
              });
              
              // Verify document was created
              final verifyDoc = await firestore.collection('users').doc(userCredential.user!.uid).get();
              if (verifyDoc.exists) {
                success = true;
                print('✅ Admin document created in Firestore');
              } else {
                retries--;
                if (retries > 0) {
                  print('⚠️ Document not found, retrying... ($retries left)');
                  await Future.delayed(Duration(seconds: 1));
                }
              }
            } catch (e) {
              retries--;
              if (retries > 0) {
                print('⚠️ Error creating document, retrying... ($retries left): $e');
                await Future.delayed(Duration(seconds: 1));
              } else {
                print('❌ Failed to create Firestore document after retries');
                rethrow;
              }
            }
          }
          
          // Logout immediately after creating admin
          await auth.signOut();
          
          print('');
          print('═══════════════════════════════════════');
          print('✅ ADMIN ACCOUNT READY!');
          print('═══════════════════════════════════════');
          print('Email    : $adminEmail');
          print('Password : $adminPassword');
          print('Role     : admin');
          print('═══════════════════════════════════════');
          print('');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('✅ Admin auth account already exists');
          // Make sure user is logged out
          await auth.signOut();
        } else {
          print('❌ Error creating admin: ${e.message}');
          rethrow;
        }
      }
    } catch (e) {
      print('❌ Error creating admin account: $e');
      rethrow;
    }
  }
}
