class AddressModel {
  String? id;
  String? addressLabel;
  String? addressType;
  String? userId;
  String? address;
  String? latitude;
  String? longitude;
  String? city;
  String? zipCode;
  String? country;
  String? zoneId;
  String? method;
  String? contactPersonName;
  String? contactPersonNumber;
  String? contactPersonLabel;
  String? street;
  String? house;
  String? floor;
  int? availableServiceCountInZone;

  AddressModel(
      {this.id,
        this.addressType,
        this.addressLabel,
        this.userId,
        this.address,
        this.latitude,
        this.longitude,
        this.city,
        this.zipCode,
        this.country,
        this.zoneId,
        this.method,
        this.contactPersonName,
        this.contactPersonNumber,
        this.contactPersonLabel,
        this.street,
        this.house,
        this.floor,
        this.availableServiceCountInZone
      });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['user_id']?.toString();
    contactPersonNumber = json['contact_person_number']?.toString();
    address = json['address']?.toString();
    addressType = json['address_type']?.toString();
    addressLabel = json['address_label']?.toString();
    latitude = json['lat']?.toString();
    longitude = json['lon']?.toString();
    city = json['city']?.toString();
    zipCode = json['zip_code']?.toString();
    country = json['country']?.toString();
    zoneId = json['zone_id']?.toString();
    contactPersonName = json['contact_person_name']?.toString();
    contactPersonLabel = json['address_label']?.toString();
    street = json['street']?.toString();
    house = json['house']?.toString();
    floor = json['floor']?.toString();
    availableServiceCountInZone = int.tryParse(json['available_service_count']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['address_label'] = addressLabel;
    data['contact_person_name'] = contactPersonName;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['lat'] = latitude;
    data['lon'] = longitude;
    data['city'] = city;
    data['zip_code'] = zipCode;
    data['country'] = country;
    data['zone_id'] = zoneId;
    data['address_label'] = addressLabel;
    data['contact_person_name'] = contactPersonName;
    data['_method'] = method;
    data['street'] = street;
    data['house'] = house;
    data['floor'] = floor;
    data['available_service_count'] = availableServiceCountInZone;
    return data;
  }
}
