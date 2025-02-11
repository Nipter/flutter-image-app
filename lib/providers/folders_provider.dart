import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/models/folder_model.dart';
import 'package:image_viewer_app/models/image/image_input_model.dart';
import 'package:image_viewer_app/models/image/image_model.dart';
import 'package:image_viewer_app/providers/images_provider.dart';
import 'package:image_viewer_app/providers/users_provider.dart';

class FoldersNotifier extends StateNotifier<List<FolderModel>> {
  FoldersNotifier() : super([]);

  Future<void> loadFolders() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('folders').get();

    List<FolderModel> folders = [];
    for (var doc in snapshot.docs) {
      FolderModel folder = await FolderModel.loadFolderWithImages(doc);
      folders.add(folder);
    }

    state = [...folders];
  }

  static Future<void> createFolder(
      List<ImageInputModel> images, String folderName) async {
    final newFolderRef = FirebaseFirestore.instance.collection('folders').doc();

    await newFolderRef.set({
      'name': folderName,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'createdBy': FirebaseAuth.instance.currentUser?.uid,
      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
      'images': [],
    });

    if (images.isNotEmpty) {
      for (ImageInputModel image in images) {
        await ImagesDataController.createImage(image, newFolderRef.id);
      }
    }
  }

  static Future<void> editFolder(
      FolderModel folder, List<ImageModel> images, String folderName) async {
    final folderRef =
        FirebaseFirestore.instance.collection('folders').doc(folder.id);

    await folderRef.update({
      'name': folderName,
      'images': images.map((image) => image.id).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
    });

    Set<String> currentImagesId =
        Set.from(folder.images.map((image) => image.id));
    Set<String> newImagesId = Set.from(images.map((image) => image.id));

    Set<String> difference = currentImagesId.difference(newImagesId);

    List<String> removedImagesId = difference.toList();

    for (String imageId in removedImagesId) {
      await ImagesDataController.deleteImage(imageId);
    }
  }

  static Future<void> deleteFolder(FolderModel folder) async {
    await FirebaseFirestore.instance
        .collection('folders')
        .doc(folder.id)
        .delete();

    for (ImageModel image in folder.images) {
      await ImagesDataController.deleteImage(image.id);
    }
  }

  static Future<void> addImageToFolder(String folderId, String imageId) async {
    await FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .update({
      'images': FieldValue.arrayUnion([imageId])
    });
  }

  static Future<void> removeImageFromFolder(
      String imageId, String folderId) async {
    await FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .update({
      'images': FieldValue.arrayRemove(
          [imageId]), // Usuwa imageId z listy, jeśli istnieje
    });
  }
}

final foldersProvider =
    StateNotifierProvider<FoldersNotifier, List<FolderModel>>((ref) {
  return FoldersNotifier();
});

final preparedFoldersProvider = Provider<List<FolderModel>>((ref) {
  final users = ref.watch(usersProvider);
  final folders = ref.watch(foldersProvider);

  return folders.map((folder) {
    final createdByUser =
        users.where((user) => user.id == folder.createdBy).toList();
    final updatedByUser = folder.createdBy == folder.updatedBy
        ? createdByUser
        : users.where((user) => user.id == folder.updatedBy).toList();

    if (!createdByUser.isEmpty && !updatedByUser.isEmpty) {
    folder.createdBy = createdByUser[0].username;
    folder.updatedBy = updatedByUser[0].username;
    }

    folder.images = folder.images.map((image) {
      final createdByUser =
          users.where((user) => user.id == image.createdBy).toList();
      final updatedByUser = image.createdBy == image.updatedBy
          ? createdByUser
          : users.where((user) => user.id == image.updatedBy).toList();

    if (!createdByUser.isEmpty && !updatedByUser.isEmpty) {
      image.createdBy = createdByUser[0].username;
      image.updatedBy = updatedByUser[0].username;
    }
      return image;
    }).toList();
    return folder;
  }).toList();
});
