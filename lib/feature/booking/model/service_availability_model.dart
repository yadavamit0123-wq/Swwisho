
class ServiceAvailabilityModel {
  String? responseCode;
  String? message;
  Content? content;

  ServiceAvailabilityModel({this.responseCode, this.message, this.content});

  ServiceAvailabilityModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    content = json['content'] is Map
        ? Content.fromJson(Map<String, dynamic>.from(json['content']))
        : null;
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

class Content {
  int? isProviderAvailable;
  int? isServiceInfoUnchanged;
  List<Services>? services;

  Content({this.isProviderAvailable, this.isServiceInfoUnchanged, this.services});

  Content.fromJson(Map<String, dynamic> json) {
    isProviderAvailable = int.tryParse(json['is_provider_available']?.toString() ?? '');
    isServiceInfoUnchanged = int.tryParse(json['is_service_info_unchanged']?.toString() ?? '');
    if (json['services'] is List) {
      services = <Services>[];
      for (final v in json['services']) {
        try {
          if (v is Map) {
            services!.add(Services.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_provider_available'] = isProviderAvailable;
    data['is_service_info_unchanged'] = isServiceInfoUnchanged;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  String? serviceId;
  String? serviceName;
  String? variantKey;
  double? serviceCost;
  double? bookingServiceCost;
  int? isAvailable;
  int? isPriceChanged;

  Services(
      {this.serviceId,
        this.serviceName,
        this.variantKey,
        this.serviceCost,
        this.bookingServiceCost,
        this.isAvailable,
        this.isPriceChanged});

  Services.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id']?.toString();
    serviceName = json['service_name']?.toString();
    variantKey = json['variant_key']?.toString();
    serviceCost = double.tryParse(json['service_unit_cost']?.toString() ?? '');
    bookingServiceCost = double.tryParse(json['booking_service_unit_cost']?.toString() ?? '');
    isAvailable = int.tryParse(json['is_available']?.toString() ?? '');
    isPriceChanged = int.tryParse(json['is_price_changed']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['variant_key'] = variantKey;
    data['service_cost'] = serviceCost;
    data['booking_service_cost'] = bookingServiceCost;
    data['is_available'] = isAvailable;
    data['is_price_changed'] = isPriceChanged;
    return data;
  }
}