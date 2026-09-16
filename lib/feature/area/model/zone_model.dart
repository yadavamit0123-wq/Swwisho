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
    name = (json['name'] ?? json['zone_name'] ?? json['display_name'])?.toString();
    if ((name == null || name!.isEmpty) && json['translations'] is List) {
      for (final item in json['translations']) {
        if (item is Map && (item['key']?.toString() == 'zone_name' || item['key']?.toString() == 'name')) {
          name = item['value']?.toString();
          if (name != null && name!.isNotEmpty) {
            break;
          }
        }
      }
    }
    if (json['formatted_coordinates'] is List) {
      formattedCoordinates = <Coordinates>[];
      for (final v in json['formatted_coordinates']) {
        try {
          if (v is Map) {
            formattedCoordinates!.add(Coordinates.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    } else if (json['coordinates'] is Map) {
      final ring = json['coordinates']['coordinates'];
      if (ring is List && ring.isNotEmpty && ring.first is List) {
        formattedCoordinates = <Coordinates>[];
        for (final point in ring.first) {
          if (point is List && point.length >= 2) {
            formattedCoordinates!.add(Coordinates(
              longitude: double.tryParse(point[0].toString()),
              latitude: double.tryParse(point[1].toString()),
            ));
          }
        }
      }
    }
    status = int.tryParse((json['status'] ?? json['is_active'])?.toString() ?? '');
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


