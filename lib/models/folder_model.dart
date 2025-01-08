import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_viewer_app/models/image/image_model.dart';
import 'package:image_viewer_app/providers/images_provider.dart';

class FolderModel {
  final String id;
  String name;
  List<ImageModel> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  String createdBy;
  String updatedBy;

  FolderModel({
    required this.id,
    required this.name,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory FolderModel.fromFirestore(
      Map<String, dynamic> data, String folderId) {
    return FolderModel(
      id: folderId,
      name: data['name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt']),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
      images: [],
    );
  }

  static Future<FolderModel> loadFolderWithImages(DocumentSnapshot doc) async {
    var data = doc.data() as Map<String, dynamic>;

    var folder = FolderModel.fromFirestore(data, doc.id);
    List<ImageModel> images =
        await ImagesDataController.loadImages(data['images']);

    return FolderModel(
      id: folder.id,
      name: folder.name,
      createdAt: folder.createdAt,
      updatedAt: folder.updatedAt,
      createdBy: folder.createdBy,
      updatedBy: folder.updatedBy,
      images: images,
    );
  }
}
