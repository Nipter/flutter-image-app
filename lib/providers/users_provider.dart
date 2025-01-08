import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/models/user_model.dart';

class UsersNotifier extends StateNotifier<List<UserModel>> {
  UsersNotifier() : super([]);

  Future<void> loadUsers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<UserModel> users = snapshot.docs
        .map(
          (doc) => UserModel.fromFirestore(doc),
        )
        .toList();
    state = users;
  }

  List<String> get currentUserRoles {
    return state.firstWhere((user) {
      return user.id == FirebaseAuth.instance.currentUser?.uid;
    }).roles;
  }
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, List<UserModel>>((ref) {
  return UsersNotifier();
});
