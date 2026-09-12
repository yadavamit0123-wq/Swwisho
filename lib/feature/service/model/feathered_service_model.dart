import 'package:demandium/feature/service/model/service_model.dart';


class FeatheredCategoryModel {
  String? responseCode;
  String? message;
  FeatheredCategoryContent? content;

  FeatheredCategoryModel({this.responseCode, this.message, this.content});

  FeatheredCategoryModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content = json['content'] != null ? FeatheredCategoryContent.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class FeatheredCategoryContent {
  int? currentPage;
  List<CategoryData>? categoryList;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? path;
  int? to;
  int? total;

  FeatheredCategoryContent(
      {this.currentPage,
        this.categoryList,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.path,
        this.to,
        this.total});

  FeatheredCategoryContent.fromJson(Map<String, dynamic> json) {
    currentPage = int.tryParse(json['current_page']?.toString() ?? '');
    if (json['data'] is List) {
      categoryList = <CategoryData>[];
      for (final v in json['data']) {
        try {
          if (v is Map) {
            categoryList!.add(CategoryData.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    firstPageUrl = json['first_page_url']?.toString();
    from = int.tryParse(json['from']?.toString() ?? '');
    lastPage = int.tryParse(json['last_page']?.toString() ?? '');
    path = json['path']?.toString();
    to = int.tryParse(json['to']?.toString() ?? '');
    total = int.tryParse(json['total']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (categoryList != null) {
      data['data'] = categoryList!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['path'] = path;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class CategoryData {
  String? id;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  int? isActive;
  int? isFeatured;
  String? createdAt;
  String? updatedAt;
  List<Service>? servicesByCategory;
  List<ServiceDiscount>? categoryDiscount;
  List<ServiceDiscount>? campaignDiscount;

  CategoryData(
      {this.id,
        this.parentId,
        this.name,
        this.image,
        this.imageFullPath,
        this.position,
        this.description,
        this.isActive,
        this.isFeatured,
        this.createdAt,
        this.updatedAt,
        this.servicesByCategory,
        this.categoryDiscount,
        this.campaignDiscount});

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    parentId = json['parent_id']?.toString();
    name = json['name']?.toString();
    image = json['image']?.toString();
    imageFullPath = json['image_full_path']?.toString();
    position = int.tryParse(json['position']?.toString() ?? '');
    description = json['description']?.toString();
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    isFeatured = int.tryParse(json['is_featured']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    if (json['services_by_category'] is List) {
      servicesByCategory = <Service>[];
      for (final v in json['services_by_category']) {
        try {
          if (v is Map) {
            servicesByCategory!.add(Service.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
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
    data['is_featured'] = isFeatured;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (servicesByCategory != null) {
      data['services_by_category'] =
          servicesByCategory!.map((v) => v.toJson()).toList();
    }

    if (categoryDiscount != null) {
      data['category_discount'] =
          categoryDiscount!.map((v) => v.toJson()).toList();
    }
    if (campaignDiscount != null) {
      data['campaign_discount'] =
          campaignDiscount!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
