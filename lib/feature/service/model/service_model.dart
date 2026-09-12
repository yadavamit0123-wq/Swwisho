import 'package:demandium/utils/core_export.dart';

class ServiceModel {
  String? responseCode;
  String? message;
  ServiceContent? content;


  ServiceModel({this.responseCode, this.message, this.content});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    if (json['content'] is Map) {
      content = ServiceContent.fromJson(Map<String, dynamic>.from(json['content']));
    }
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

class ServiceContent {
  int? currentPage;
  List<Service>? serviceList;
  int? from;
  int? lastPage;
  int? total;

  ServiceContent({
    this.currentPage,
    this.serviceList,
    this.from,
    this.lastPage,
    this.total,
  });

  ServiceContent.fromJson(Map<String, dynamic> json) {
    currentPage = int.tryParse(json['current_page']?.toString() ?? '');
    if (json['data'] is List) {
      serviceList = <Service>[];
      for (final v in json['data']) {
        try {
          if (v is Map) {
            serviceList!.add(Service.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    from = int.tryParse(json['from']?.toString() ?? '');
    lastPage = int.tryParse(json['last_page']?.toString() ?? '');
    total = int.tryParse(json['total']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (serviceList != null) {
      data['data'] = serviceList!.map((v) => v.toJson()).toList();
    }
    data['from'] = from;
    data['last_page'] = lastPage;
    data['total'] = total;
    return data;
  }
}

class Service {
  String? id;
  String? name;
  String? shortDescription;
  String? description;
  String? coverImage;
  String? coverImageFullPath;
  String? thumbnail;
  String? thumbnailFullPath;
  String? categoryId;
  String? subCategoryId;
  double? tax;
  int? orderCount;
  int? isActive;
  int? isFavorite;
  int? ratingCount;
  double? avgRating;
  String? createdAt;
  String? updatedAt;
  ServiceCategory? category;
  VariationsAppFormat? variationsAppFormat;
  List<Variations>? variations;
  List<Faqs>? faqs;
  List<ServiceDiscount>? serviceDiscount;
  List<ServiceDiscount>? campaignDiscount;
  List<Review>? review;

  Service(
      {this.id,
        this.name,
        this.shortDescription,
        this.description,
        this.coverImage,
        this.coverImageFullPath,
        this.thumbnail,
        this.thumbnailFullPath,
        this.categoryId,
        this.subCategoryId,
        this.tax,
        this.orderCount,
        this.isActive,
        this.isFavorite,
        this.ratingCount,
        this.avgRating,
        this.createdAt,
        this.updatedAt,
        this.category,
        this.variationsAppFormat,
        this.variations,
        this.faqs,
        this.serviceDiscount,
        this.campaignDiscount,
        this.review,
      });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    shortDescription = json['short_description']?.toString();
    description = json['description']?.toString();
    coverImage = json['cover_image']?.toString();
    coverImageFullPath = json['cover_image_full_path']?.toString();
    thumbnail = json['thumbnail']?.toString();
    thumbnailFullPath = json['thumbnail_full_path']?.toString();
    categoryId = json['category_id']?.toString();
    subCategoryId = json['sub_category_id']?.toString();
    tax = double.tryParse(json['tax']?.toString() ?? '');
    orderCount = int.tryParse(json['order_count']?.toString() ?? '');
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    isFavorite = int.tryParse(json['is_favorite']?.toString() ?? '');
    ratingCount = int.tryParse(json['rating_count']?.toString() ?? '');
    avgRating = double.tryParse(json['avg_rating']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    try {
      if (json['variations_app_format'] is Map) {
        variationsAppFormat = VariationsAppFormat.fromJson(
          Map<String, dynamic>.from(json['variations_app_format']),
        );
      }
    } catch (_) {}

    if (json['variations'] is List) {
      variations = <Variations>[];
      for (final v in json['variations']) {
        try {
          if (v is Map) {
            variations!.add(Variations.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }

    if (json['reviews'] is List) {
      review = <Review>[];
      for (final v in json['reviews']) {
        try {
          if (v is Map) {
            review!.add(Review.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }

    try {
      if (json['category'] is Map) {
        category = ServiceCategory.fromJson(Map<String, dynamic>.from(json['category']));
      }
    } catch (_) {}
    if (json['faqs'] is List) {
      faqs = <Faqs>[];
      for (final v in json['faqs']) {
        try {
          if (v is Map) {
            faqs!.add(Faqs.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    if (json['service_discount'] is List) {
      serviceDiscount = <ServiceDiscount>[];
      for (final v in json['service_discount']) {
        try {
          if (v is Map) {
            serviceDiscount!.add(ServiceDiscount.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    if (json['campaign_discount'] is List) {
      campaignDiscount = <ServiceDiscount>[];
      for (final v in json['campaign_discount']) {
        try {
          if (v is Map) {
            campaignDiscount!.add(ServiceDiscount.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['short_description'] = shortDescription;
    data['description'] = description;
    data['cover_image'] = coverImage;
    data['cover_image_full_path'] = coverImageFullPath;
    data['thumbnail'] = thumbnail;
    data['thumbnail_full_path'] = thumbnailFullPath;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['tax'] = tax;
    data['order_count'] = orderCount;
    data['is_active'] = isActive;
    data['is_favorite'] = isFavorite;
    data['rating_count'] = ratingCount;
    data['avg_rating'] = avgRating;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (variationsAppFormat != null) {
      data['variations_app_format'] = variationsAppFormat!.toJson();
    }

    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (review != null) {
      data['reviews'] = review!.map((v) => v.toJson()).toList();
    }

    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    if (serviceDiscount != null) {
      data['service_discount'] = serviceDiscount!.map((v) => v.toJson()).toList();
    }
    if (campaignDiscount != null) {
      data['campaign_discount'] = campaignDiscount!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationsAppFormat {
  String? zoneId;
  double? defaultPrice;
  List<ZoneWiseVariations>? zoneWiseVariations;

  VariationsAppFormat(
      {this.zoneId, this.defaultPrice, this.zoneWiseVariations});

  VariationsAppFormat.fromJson(Map<String, dynamic> json) {
    zoneId = json['zone_id']?.toString();
    defaultPrice = double.tryParse(json['default_price']?.toString() ?? '');
    if (json['zone_wise_variations'] is List) {
      zoneWiseVariations = <ZoneWiseVariations>[];
      for (final v in json['zone_wise_variations']) {
        try {
          if (v is Map) {
            zoneWiseVariations!.add(ZoneWiseVariations.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['zone_id'] = zoneId;
    data['default_price'] = defaultPrice;
    if (zoneWiseVariations != null) {
      data['zone_wise_variations'] =
          zoneWiseVariations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variations {
  int? id;
  String? variant;
  String? variantKey;
  String? serviceId;
  String? zoneId;
  num? price;
  String? createdAt;
  String? updatedAt;
  Zone? zone;

  Variations(
      {this.id,
        this.variant,
        this.variantKey,
        this.serviceId,
        this.zoneId,
        this.price,
        this.createdAt,
        this.updatedAt,
        this.zone});

  Variations.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    variant = json['variant']?.toString();
    variantKey = json['variant_key']?.toString();
    serviceId = json['service_id']?.toString();
    zoneId = json['zone_id']?.toString();
    price = num.tryParse(json['price']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['variant'] = variant;
    data['variant_key'] = variantKey;
    data['service_id'] = serviceId;
    data['zone_id'] = zoneId;
    data['price'] = price;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ZoneWiseVariations {
  String? variantKey;
  String? variantName;
  num? price;

  ZoneWiseVariations({this.variantKey, this.variantName, this.price,});

  ZoneWiseVariations.fromJson(Map<String, dynamic> json) {
    variantKey = json['variant_key']?.toString();
    variantName = json['variant_name']?.toString();
    price = num.tryParse(json['price']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_key'] = variantKey;
    data['variant_name'] = variantName;
    data['price'] = price;
    return data;
  }
}
class ServiceCategory {
  String? id;
  String? parentId;
  String? name;
  String? image;
  int? position;
  String? description;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  List<ServiceDiscount>? categoryDiscount;
  List<ServiceDiscount>? campaignDiscount;


  ServiceCategory(
      {this.id,
        this.parentId,
        this.name,
        this.image,
        this.position,
        this.description,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.categoryDiscount,
        this.campaignDiscount,
      });

  ServiceCategory.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    parentId = json['parent_id']?.toString();
    name = json['name']?.toString();
    image = json['image']?.toString();
    position = int.tryParse(json['position']?.toString() ?? '');
    description = json['description']?.toString();
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

    if (json['category_discount'] != null) {
      categoryDiscount = <ServiceDiscount>[];
      json['category_discount'].forEach((v) {
        categoryDiscount!.add(ServiceDiscount.fromJson(v));
      });
    }
    if (json['campaign_discount'] != null) {
      campaignDiscount = <ServiceDiscount>[];
      json['campaign_discount'].forEach((v) {
        campaignDiscount!.add(ServiceDiscount.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    if (categoryDiscount != null) {
      data['category_discount'] = categoryDiscount!.map((v) => v.toJson()).toList();
    }
    if (campaignDiscount != null) {
      data['campaign_discount'] = campaignDiscount!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class ZonesBasicInfo {
  String? id;
  String? name;
  List<Coordinates>? coordinates;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  ZonesBasicInfo(
      {this.id,
        this.name,
        this.coordinates,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.pivot});

  ZonesBasicInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['coordinates'] != null) {
      coordinates = <Coordinates>[];
      json['coordinates'].forEach((v) {
        coordinates!.add(Coordinates.fromJson(v));
      });
    }
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.map((v) => v.toJson()).toList();
    }
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}
class Faqs {
  String? id;
  String? question;
  String? answer;
  String? serviceId;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  Faqs(
      {this.id,
        this.question,
        this.answer,
        this.serviceId,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  Faqs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    serviceId = json['service_id'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['answer'] = answer;
    data['service_id'] = serviceId;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
class ServiceDiscount {
  int? id;
  String? discountId;
  String? discountType;
  String? typeWiseId;
  String? createdAt;
  String? updatedAt;
  Discount? discount;

  ServiceDiscount(
      {this.id,
        this.discountId,
        this.discountType,
        this.typeWiseId,
        this.createdAt,
        this.updatedAt,
        this.discount});

  ServiceDiscount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    discountId = json['discount_id'];
    discountType = json['discount_type'];
    typeWiseId = json['type_wise_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    discount = json['discount'] != null
        ? Discount.fromJson(json['discount'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['discount_id'] = discountId;
    data['discount_type'] = discountType;
    data['type_wise_id'] = typeWiseId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    return data;
  }
}
