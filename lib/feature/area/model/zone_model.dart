import 'package:demandium/utils/core_export.dart';

class ZoneModel {
  String? id;
  String? name;
  List<Coordinates>? formattedCoordinates;
  int? status;
  String? createdAt;
  String? updatedAt;


  ZoneModel({this.id, this.name, this.formattedCoordinates, this.status, this.createdAt, this.updatedAt});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    if (json['formatted_coordinates'] is List) {
      formattedCoordinates = <Coordinates>[];
      for (final v in json['formatted_coordinates']) {
        try {
          if (v is Map) {
            formattedCoordinates!.add(Coordinates.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    status = int.tryParse(json['status']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (formattedCoordinates != null) {
      data['formatted_coordinates'] = formattedCoordinates!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


