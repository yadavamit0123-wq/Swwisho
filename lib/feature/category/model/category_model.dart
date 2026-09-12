import 'package:flutter/material.dart';

class CategoryModel {
  String? id;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? serviceCount;
  GlobalKey? globalKey;

  CategoryModel(
      {this.id,
        this.parentId,
        this.name,
        this.image,
        this.imageFullPath,
        this.position,
        this.description,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.serviceCount,
        this.globalKey,
      });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    parentId = json['parent_id']?.toString();
    name = json['name']?.toString();
    image = json['image']?.toString();
    imageFullPath = json['image_full_path']?.toString();
    position = int.tryParse(json['position']?.toString() ?? '');
    description = json['description']?.toString();
    isActive = int.tryParse(json['is_active']?.toString() ?? '') == 1;
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    serviceCount = int.tryParse(json['services_count']?.toString() ?? '');
    globalKey = GlobalKey(debugLabel: id ?? 'category');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['image_full_path'] = imageFullPath;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['services_count'] = serviceCount;
    return data;
  }
}
