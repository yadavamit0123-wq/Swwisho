import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class ServiceAreaScreen extends StatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  State<ServiceAreaScreen> createState() => _ServiceAreaScreenState();
}

class _ServiceAreaScreenState extends State<ServiceAreaScreen> {
  bool _loading = true;
  String? _error;
  List<ZoneModel> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is String && data.isNotEmpty) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is List) {
      return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (data is Map) {
      final content = data['content'];
      dynamic list;
      if (content is Map) {
        list = content['data'] ?? content['zones'];
      } else if (content is List) {
        list = content;
      } else {
        list = data['data'];
      }
      if (list is List) {
        return list.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }
    return [];
  }

  Future<void> _loadZones() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await HomeScreen.ensureZoneHeader();
      final response = await Get.find<ApiClient>().postData(AppConstants.getZoneListApi, {});
      final zones = <ZoneModel>[];
      for (final item in _extractList(response.body)) {
        try {
          zones.add(ZoneModel.fromJson(item));
        } catch (_) {}
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _zones = zones;
        _loading = false;
        if (zones.isEmpty) {
          _error = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Service areas load nahi ho paayi. Pull to refresh karke try karein.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentZoneId = Get.find<LocationController>().getUserAddress()?.zoneId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text('our_services_areas'.tr),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadZones,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const Icon(Icons.location_on_outlined, size: 48, color: Color(0xFF667085)),
            const SizedBox(height: 12),
            Text(
              'we_are_available_in_these_areas'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'get_you_desired_service'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (!_loading && _error != null)
              Column(
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _loadZones, child: const Text('Retry')),
                ],
              ),
            if (!_loading && _error == null && _zones.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No service area found')),
              ),
            if (!_loading)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _zones.map((zone) {
                  final selected = currentZoneId != null && currentZoneId == zone.id;
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 42) / 2,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).primaryColor.withValues(alpha: 0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.4)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (selected)
                            Text(
                              'your_area'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          Text(
                            zone.name ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
