import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final String id;
  final String imageCloudId;
  String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  String createdBy;
  String updatedBy;
  String metadata;

  ImageModel({
    required this.id,
    required this.imageCloudId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.metadata,
  });

  factory ImageModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

          
    return ImageModel(
      id: doc.id,
      imageCloudId: data['imageCloudId'],
      name: data['name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt']),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
      metadata: data['metadata'].toString(),
    );
  }
}
