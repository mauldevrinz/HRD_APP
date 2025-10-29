import 'package:flutter/foundation.dart';

class UserProfile {
  String name;
  String email;
  String? photoUrl;

  UserProfile({
    required this.name,
    required this.email,
    this.photoUrl,
  });
}

class UserProfileProvider extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(
    name: 'Fatimatuz Zahro',
    email: 'ahmad.maulana@example.com',
    photoUrl: 'https://via.placeholder.com/50',
  );

  UserProfile get userProfile => _userProfile;

  void updateProfile({String? name, String? email, String? photoUrl}) {
    if (name != null) _userProfile.name = name;
    if (email != null) _userProfile.email = email;
    if (photoUrl != null) _userProfile.photoUrl = photoUrl;
    notifyListeners();
  }
}