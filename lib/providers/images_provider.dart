import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_viewer_app/models/image/image_input_model.dart';
import 'package:image_viewer_app/models/image/image_model.dart';

import 'package:image_viewer_app/providers/folders_provider.dart';
import 'package:uuid/uuid.dart';

class ImagesDataController {
  static Future<List<ImageModel>> loadImages(List<dynamic> imagesId) async {
    List<ImageModel> images = [];

    for (String imageId in imagesId) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('images')
          .doc(imageId)
          .get();

      if (doc.exists) {
        ImageModel image = ImageModel.fromFirestore(doc);
        images.add(image);
      }
    }
    return images;
  }

  static Future<void> createImage(
      ImageInputModel image, String folderId) async {
    final collectionRef = FirebaseFirestore.instance.collection('images');

    final newDocRef = collectionRef.doc();

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images')
        .child('${const Uuid().v4()}.png');

    await storageRef.putData(
      image.imageBytes,
      SettableMetadata(contentType: 'image/png'),
    );

    await newDocRef.set({
      'name': image.name,
      'imageCloudId': storageRef.fullPath,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'createdBy': FirebaseAuth.instance.currentUser?.uid,
      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
    });
    await FoldersNotifier.addImageToFolder(folderId, newDocRef.id);
  }

  static Future<void> editImage(ImageModel image, String folderId) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('images').doc(image.id);

    await collectionRef.update({
      'name': image.name,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
    });

    await FoldersNotifier.removeImageFromFolder(folderId, folderId);
    await FoldersNotifier.addImageToFolder(folderId, folderId);
  }

  static Future<void> deleteImage(String imageId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('images')
        .doc(imageId)
        .get();

    if (doc.exists) {
      ImageModel image = ImageModel.fromFirestore(doc);
      final storageRef =
          FirebaseStorage.instance.ref().child(image.imageCloudId);

      await storageRef.delete();
    }
    await FirebaseFirestore.instance.collection('images').doc(imageId).delete();
  }

  static Future<void> deleteImageWithFromFolder(
      String imageId, String folderId) async {
    await deleteImage(imageId);
    await FoldersNotifier.removeImageFromFolder(imageId, folderId);
  }
}
