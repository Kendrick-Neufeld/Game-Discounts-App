import 'dart:typed_data';

class User {
  final int id;
  final String username;
  final String password;
  final String email;
  final Uint8List? profilePicture;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.profilePicture,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      profilePicture: map['profile_picture'],
    );
  }
}
