import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      username: data['username'],
      email: data['email'],
      roles: List<String>.from(data['roles']),
    );
  }
}
