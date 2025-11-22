import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class UserProfile {
  String name;
  String email;
  String? photoUrl;
  String? department;
  String? employeeId;
  String role;

  UserProfile({
    required this.name,
    required this.email,
    this.photoUrl,
    this.department,
    this.employeeId,
    this.role = 'employee',
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      department: map['department'],
      employeeId: map['employeeId'],
      role: map['role'] ?? 'employee',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'department': department,
      'employeeId': employeeId,
      'role': role,
    };
  }
}

class UserProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;
  
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // Load user profile from Firestore
  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
        await _saveToLocalStorage();
      } else {
        // Document doesn't exist, create default profile from Firebase Auth
        debugPrint('User document not found, creating default profile');
        _userProfile = UserProfile(
          name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          role: 'employee',
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Try to load from local storage or create default
      await _loadFromLocalStorage();
      if (_userProfile == null && user.email != null) {
        _userProfile = UserProfile(
          name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          role: 'employee',
        );
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update profile in Firestore
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? department,
    String? employeeId,
    bool clearPhoto = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (clearPhoto) updates['photoUrl'] = null;
      if (department != null) updates['department'] = department;
      if (employeeId != null) updates['employeeId'] = employeeId;

      await _firestore.collection('users').doc(user.uid).update(updates);

      // Update local profile
      if (_userProfile != null) {
        if (name != null) _userProfile!.name = name;
        if (email != null) _userProfile!.email = email;
        if (photoUrl != null) _userProfile!.photoUrl = photoUrl;
        if (clearPhoto) _userProfile!.photoUrl = null;
        if (department != null) _userProfile!.department = department;
        if (employeeId != null) _userProfile!.employeeId = employeeId;
        
        await _saveToLocalStorage();
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Upload profile photo
  Future<String?> uploadProfilePhoto(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('User not authenticated');
      return null;
    }

    try {
      // Check file exists
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist');
        return null;
      }

      // Check file size (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        debugPrint('File size is too large: $fileSize bytes');
        return null;
      }

      debugPrint('Starting upload for user: ${user.uid}');
      
      final fileName = '${user.uid}.jpg';
      final ref = _storage.ref('profile_photos').child(fileName);
      
      debugPrint('Uploading to: profile_photos/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final taskSnapshot = await uploadTask;
      debugPrint('Upload complete');
      
      final url = await ref.getDownloadURL();
      debugPrint('Got download URL: $url');
      
      // Update profile with new URL
      await updateProfile(photoUrl: url);
      debugPrint('Profile updated with photo URL');
      return url;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }

  // Delete profile photo
  Future<bool> deleteProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      debugPrint('Starting delete for user: ${user.uid}');
      
      final fileName = '${user.uid}.jpg';
      final ref = _storage.ref('profile_photos').child(fileName);
      
      // Try to delete from storage (may not exist, that's ok)
      try {
        await ref.delete();
        debugPrint('Photo deleted from storage');
      } catch (e) {
        debugPrint('File may not exist in storage: $e');
      }
      
      // Update profile to remove photoUrl
      await updateProfile(clearPhoto: true);
      debugPrint('Profile updated - photo removed');
      
      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }

  // Save to local storage for offline access
  Future<void> _saveToLocalStorage() async {
    if (_userProfile == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _userProfile!.name);
      await prefs.setString('user_email', _userProfile!.email);
      if (_userProfile!.photoUrl != null) {
        await prefs.setString('user_photo', _userProfile!.photoUrl!);
      }
      if (_userProfile!.department != null) {
        await prefs.setString('user_department', _userProfile!.department!);
      }
      if (_userProfile!.employeeId != null) {
        await prefs.setString('user_employee_id', _userProfile!.employeeId!);
      }
      await prefs.setString('user_role', _userProfile!.role);
    } catch (e) {
      debugPrint('Error saving to local storage: $e');
    }
  }

  // Load from local storage
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      
      if (name != null && email != null) {
        _userProfile = UserProfile(
          name: name,
          email: email,
          photoUrl: prefs.getString('user_photo'),
          department: prefs.getString('user_department'),
          employeeId: prefs.getString('user_employee_id'),
          role: prefs.getString('user_role') ?? 'employee',
        );
      }
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
    }
  }

  // Clear profile (on logout)
  Future<void> clearProfile() async {
    _userProfile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}