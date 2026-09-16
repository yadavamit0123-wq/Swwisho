import 'package:demandium/utils/core_export.dart';

class SearchServiceModel {
  String? responseCode;
  String? message;
  Content? content;


  SearchServiceModel({this.responseCode, this.message, this.content});

  SearchServiceModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    if (json['content'] is Map) {
      content = Content.fromJson(Map<String, dynamic>.from(json['content']));
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

class Content {
  double? initialMinPrice;
  double? initialMaxPrice;
  double? filteredMinPrice;
  double? filteredMaxPrice;
  ServiceContent? servicesContent;

  Content({this.initialMinPrice, this.initialMaxPrice, this.servicesContent});

  Content.fromJson(Map<String, dynamic> json) {
    initialMinPrice = double.tryParse('${json['initial_min_price'] ?? ''}');
    initialMaxPrice = double.tryParse('${json['initial_max_price'] ?? ''}');
    filteredMinPrice = double.tryParse('${json['filter_min_price'] ?? ''}');
    filteredMaxPrice = double.tryParse('${json['filter_max_price'] ?? ''}');
    final services = json['services'] ?? json['data'];
    if (services is Map) {
      servicesContent = ServiceContent.fromJson(Map<String, dynamic>.from(services));
    } else if (services is List) {
      servicesContent = ServiceContent.fromJson({'data': services});
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min_price'] = initialMinPrice;
    data['max_price'] = initialMaxPrice;
    if (servicesContent != null) {
      data['services'] = servicesContent!.toJson();
    }
    return data;
  }
}

