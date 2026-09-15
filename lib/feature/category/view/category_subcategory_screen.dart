import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class CategorySubCategoryScreen extends StatefulWidget {
  final String categoryID;
  final String categoryIndex;
  const CategorySubCategoryScreen({super.key, required this.categoryID, required this.categoryIndex});

  @override
  State<CategorySubCategoryScreen> createState() => _CategorySubCategoryScreenState();
}

class _CategorySubCategoryScreenState extends State<CategorySubCategoryScreen> {
  bool _loading = true;
  String? _error;
  String _selectedCategoryId = '';
  List<CategoryModel> _categories = [];
  List<CategoryModel> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryID;
    _load();
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
        list = content['data'] ?? content['categories'];
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await HomeScreen.ensureZoneHeader();
      final api = Get.find<ApiClient>();
      final categoryResponse = await api.getData('${AppConstants.categoryUrl}&limit=100&offset=1');
      final categories = <CategoryModel>[];
      for (final item in _extractList(categoryResponse.body)) {
        try {
          categories.add(CategoryModel.fromJson(item));
        } catch (_) {}
      }

      if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id ?? '';
      }

      final subCategories = await _fetchSubCategories(_selectedCategoryId);

      if (!mounted) {
        return;
      }
      setState(() {
        _categories = categories;
        _subCategories = subCategories;
        _loading = false;
        if (categories.isEmpty && subCategories.isEmpty) {
          _error = 'Categories load nahi ho paayi. Pull to refresh karke try karein.';
        }
      });

      try {
        Get.find<CategoryController>().seedCategoryList(categories);
      } catch (_) {}
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Categories load nahi ho paayi. Pull to refresh karke try karein.';
      });
    }
  }

  Future<List<CategoryModel>> _fetchSubCategories(String categoryId) async {
    if (categoryId.isEmpty) {
      return [];
    }
    try {
      final response = await Get.find<ApiClient>().getData('${AppConstants.subCategoryUri}$categoryId');
      final subCategories = <CategoryModel>[];
      for (final item in _extractList(response.body)) {
        try {
          final model = CategoryModel.fromJson(item);
          if (model.isActive != false) {
            subCategories.add(model);
          }
        } catch (_) {}
      }
      return subCategories;
    } catch (_) {
      return [];
    }
  }

  Future<void> _onCategoryTap(CategoryModel category) async {
    final id = category.id;
    if (id == null || id.isEmpty || id == _selectedCategoryId) {
      return;
    }
    setState(() {
      _selectedCategoryId = id;
      _loading = true;
    });
    final subCategories = await _fetchSubCategories(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _subCategories = subCategories;
      _loading = false;
    });
  }

  void _openSubCategory(CategoryModel subCategory) {
    final id = subCategory.id;
    if (id == null || id.isEmpty) {
      return;
    }
    Get.to(() => _SubCategoryServicesScreen(subCategory: subCategory));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text('available_service'.tr),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: _categories.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final selected = category.id == _selectedCategoryId;
                        return InkWell(
                          onTap: () => _onCategoryTap(category),
                          child: Container(
                            width: 96,
                            height: 108,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected ? Theme.of(context).primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 42,
                                  width: 42,
                                  child: CustomImage(
                                    image: category.imageFullPath ?? '',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    category.name ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: selected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'sub_categories'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (!_loading && _error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            if (!_loading && _error == null && _subCategories.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Center(child: Text('No sub category found')),
              ),
            if (!_loading)
              ..._subCategories.map((subCategory) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: InkWell(
                    onTap: () => _openSubCategory(subCategory),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 72,
                              width: 72,
                              child: CustomImage(
                                image: subCategory.imageFullPath ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subCategory.name ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                if ((subCategory.description ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subCategory.description ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  '${subCategory.serviceCount ?? 0} ${'services'.tr}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryServicesScreen extends StatefulWidget {
  final CategoryModel subCategory;
  const _SubCategoryServicesScreen({required this.subCategory});

  @override
  State<_SubCategoryServicesScreen> createState() => _SubCategoryServicesScreenState();
}

class _SubCategoryServicesScreenState extends State<_SubCategoryServicesScreen> {
  bool _loading = true;
  List<Service> _services = [];

  @override
  void initState() {
    super.initState();
    _load();
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
        list = content['data'] ?? content['services'];
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

  Future<void> _load() async {
    try {
      await HomeScreen.ensureZoneHeader();
      final id = widget.subCategory.id ?? '';
      final response = await Get.find<ApiClient>().getData('${AppConstants.serviceBasedOnSubCategory}$id?limit=50&offset=1');
      final services = <Service>[];
      for (final item in _extractList(response.body)) {
        try {
          services.add(Service.fromJson(item));
        } catch (_) {}
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _services = services;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(widget.subCategory.name ?? 'services'.tr),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _services.isEmpty
              ? const Center(child: Text('No service found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          final id = service.id;
                          if (id == null || id.isEmpty) {
                            return;
                          }
                          Get.toNamed(RouteHelper.getServiceRoute(id));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  height: 72,
                                  width: 72,
                                  child: CustomImage(
                                    image: service.thumbnailFullPath ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  service.name ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => ServiceCenterDialog(service: service),
                                  );
                                },
                                icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

