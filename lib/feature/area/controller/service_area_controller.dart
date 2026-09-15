import 'dart:ui';

import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';


class ServiceAreaController extends GetxController implements GetxService{
  ServiceAreaRepo serviceAreaRepo;
  ServiceAreaController({required this.serviceAreaRepo});

  List<ZoneModel>? _zoneList;

  Set<Marker> _markers = {};
  Set<Polygon> _polygone = {};


  List<ZoneModel>? get zoneList => _zoneList;
  Set<Marker> get markers => _markers;
  Set<Polygon> get polygone => _polygone;


  List<ZoneModel> _parseZoneList(dynamic data) {
    final zones = <ZoneModel>[];
    if (data is! Map) {
      return zones;
    }

    final content = data['content'];
    final list = content is Map
        ? content['data']
        : (content is List ? content : data['data']);

    if (list is List) {
      for (final zone in list) {
        try {
          if (zone is Map) {
            zones.add(ZoneModel.fromJson(Map<String, dynamic>.from(zone)));
          }
        } catch (_) {}
      }
    }
    return zones;
  }

  Set<Polygon> _buildPolygons(List<ZoneModel> zones) {
    final polygonList = <Polygon>[];

    for (int index = 0; index < zones.length; index++) {
      final coordinates = zones[index].formattedCoordinates ?? [];
      final zoneLatLongList = <LatLng>[];

      for (final coordinate in coordinates) {
        final lat = coordinate.latitude;
        final lng = coordinate.longitude;
        if (lat != null && lng != null) {
          zoneLatLongList.add(LatLng(lat, lng));
        }
      }

      if (zoneLatLongList.isEmpty) {
        continue;
      }

      polygonList.add(
        Polygon(
          polygonId: PolygonId('zone$index'),
          points: zoneLatLongList,
          strokeWidth: 2,
          strokeColor: Get.theme.colorScheme.primary,
          fillColor: Get.theme.colorScheme.primary.withValues(alpha: .2),
        ),
      );
    }

    return HashSet<Polygon>.of(polygonList);
  }

  Future<void> getZoneList({Map<String, GlobalKey>? globalKeyMap, bool reload = true}) async {
    if (reload || _zoneList == null) {
      _zoneList = null;
      update();
    }

    try {
      await DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: ()=> serviceAreaRepo.getZoneList<CacheResponseData>(source: DataSourceEnum.local),
        fetchFromClient: ()=> serviceAreaRepo.getZoneList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          _zoneList = _parseZoneList(data);
          _polygone = _buildPolygons(_zoneList ?? []);
          update();
        },
      );
    } catch (_) {
    } finally {
      _zoneList ??= [];
      update();
    }
  }

  Future<void> setMarker(List<ZoneModel> zoneList, Map<String, GlobalKey> globalKeymap) async {

    List<Marker> markerList = [];

    for (int index = 0; index < zoneList.length; index++) {
      final coordinates = zoneList[index].formattedCoordinates ?? [];
      if (coordinates.isEmpty) {
        continue;
      }

      markerList.add(Marker(
        infoWindow: GetPlatform.isWeb || GetPlatform.isIOS ? InfoWindow(
            title: zoneList[index].name ?? ''
        ) : InfoWindow.noText,
        markerId: MarkerId('provider$index'),
        icon: GetPlatform.isWeb || GetPlatform.isIOS ? BitmapDescriptor.defaultMarker : await MarkerIcon.widgetToIcon(globalKeymap[index.toString()]!) ,
        position: computeCentroid(coordinates : coordinates),
      ));
    }
    _markers = HashSet<Marker>.of(markerList);
  }


  LatLng computeCentroid({List<Coordinates> ? coordinates, Iterable<LatLng>? points}) {
    double latitude = 0;
    double longitude = 0;
    int n = 1;

    if(points !=null && points.isNotEmpty){
     n = points.length;

     for (LatLng point in points) {
       latitude += point.latitude;
       longitude += point.longitude;
     }

    } else if(coordinates !=null && coordinates.isNotEmpty){
      n = coordinates.length;

      for (Coordinates point in coordinates) {
        latitude += point.latitude ?? 0;
        longitude += point.longitude ?? 0;
      }

    }else{
      n = 1;
    }

    return LatLng(latitude / n, longitude / n);
  }


  Future<Uint8List?> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))?.buffer.asUint8List();
  }


  void mapBound(GoogleMapController controller) async {
    List<LatLng> latLongList = [];
    for (int index = 0; index < (_zoneList?.length ?? 0); index++) {
      final coordinates = _zoneList![index].formattedCoordinates ?? [];
      for (final coordinate in coordinates) {
        final lat = coordinate.latitude;
        final lng = coordinate.longitude;
        if (lat != null && lng != null) {
          latLongList.add(LatLng(lat, lng));
        }
      }
    }

    if (latLongList.isEmpty) {
      return;
    }

    await controller.getVisibleRegion();
    Future.delayed(const Duration(milliseconds: 100), () {
      controller.animateCamera(CameraUpdate.newLatLngBounds(
        MapHelper.boundsFromLatLngList(latLongList),
        100.5,
      ));
    });

    update();
  }



}
