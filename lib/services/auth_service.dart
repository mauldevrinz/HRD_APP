import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update last login or create document if not exists
      if (result.user != null) {
        try {
          // Check if document exists
          final doc = await _firestore.collection('users').doc(result.user!.uid).get();
          
          if (doc.exists) {
            // Update last login
            await _firestore.collection('users').doc(result.user!.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } else {
            // Document doesn't exist, create it
            print('⚠️ User document not found, creating new one');
            await _firestore.collection('users').doc(result.user!.uid).set({
              'userId': result.user!.uid,
              'email': result.user!.email,
              'name': result.user!.displayName ?? result.user!.email?.split('@')[0] ?? 'User',
              'role': result.user!.email == 'admin@gmail.com' ? 'admin' : 'employee',
              'department': result.user!.email == 'admin@gmail.com' ? 'IT' : '',
              'employeeId': result.user!.email == 'admin@gmail.com' ? 'ADMIN001' : '',
              'photoUrl': result.user!.photoURL ?? '',
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': FieldValue.serverTimestamp(),
            });
            print('✅ User document created');
          }
        } catch (e) {
          print('⚠️ Error updating/creating user document: $e');
        }
      }

      return {
        'success': true,
        'user': result.user,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun dinonaktifkan';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? department,
    String? employeeId,
  }) async {
    UserCredential? result;
    try {
      // Create user in Firebase Auth
      result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user document in Firestore
      if (result.user != null) {
        try {
          await _firestore.collection('users').doc(result.user!.uid).set({
            'userId': result.user!.uid,
            'email': email.trim(),
            'name': name,
            'role': 'employee', // Default role
            'department': department ?? '',
            'employeeId': employeeId ?? '',
            'photoUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } catch (firestoreError) {
          // If Firestore fails, delete the created auth user
          await result.user!.delete();
          return {
            'success': false,
            'message': 'Gagal menyimpan data: ${firestoreError.toString()}',
          };
        }

        // Skip display name update to avoid PigeonUserDetails error
        // Name is already stored in Firestore
      }

      return {
        'success': true,
        'user': result.user,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      switch (e.code) {
        case 'weak-password':
          message = 'Password terlalu lemah (min. 6 karakter)';
          break;
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'operation-not-allowed':
          message = 'Registrasi tidak diizinkan';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      // If any other error occurs after user creation, try to delete the user
      if (result?.user != null) {
        try {
          await result!.user!.delete();
        } catch (_) {}
      }
      
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['role'] == 'admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Email reset password telah dikirim',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
