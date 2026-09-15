import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/models/category_types_model.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryRepo categoryRepo;
  CategoryController({required this.categoryRepo});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList;
  List<Service>? _searchProductList = [];
  List<CategoryModel>? _campaignBasedCategoryList ;

  bool _isLoading = false;
  int? _pageSize;
  bool? _isSearching = false;
  final String _type = 'all';
  final String _searchText = '';

  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get campaignBasedCategoryList => _campaignBasedCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  List<Service>? get searchServiceList => _searchProductList;
  bool get isLoading => _isLoading;
  int? get pageSize => _pageSize;
  bool? get isSearching => _isSearching;
  String? get type => _type;
  String? get searchText => _searchText;


  Future<void> getCategoryList(bool reload ) async {

    if(_categoryList == null || reload){
      await DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: ()=> categoryRepo.getCategoryList<CacheResponseData>( source: DataSourceEnum.local),
        fetchFromClient: ()=> categoryRepo.getCategoryList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          _categoryList = [];
          try {
            dynamic list;
            if (data is Map) {
              final content = data['content'];
              if (content is Map) {
                list = content['data'];
              } else if (content is List) {
                list = content;
              } else {
                list = data['data'];
              }
            } else if (data is List) {
              list = data;
            }
            if (list is List) {
              for (final category in list) {
                try {
                  if (category is Map) {
                    _categoryList!.add(CategoryModel.fromJson(Map<String, dynamic>.from(category)));
                  }
                } catch (_) {}
              }
            }
          } catch (_) {}
          try {
            if (Get.isRegistered<AllSearchController>()) {
              Get.find<AllSearchController>().insertCategoryCheckedList();
            }
          } catch (_) {}
          update();
        },
      );
    }
  }


  Future<void> getSubCategoryList(String categoryID, {bool shouldUpdate = true}) async {
    _subCategoryList = null;
    if(shouldUpdate){
      update();
    }
    try {
      Response response = await categoryRepo.getSubCategoryList(categoryID);
      _subCategoryList = [];
      if (response.statusCode == 200 && response.body is Map) {
        dynamic list;
        final content = response.body['content'];
        if (content is Map) {
          list = content['data'];
        } else if (content is List) {
          list = content;
        }
        if (list is List) {
          for (final category in list) {
            try {
              if (category is Map) {
                final model = CategoryModel.fromJson(Map<String, dynamic>.from(category));
                if (model.isActive != false) {
                  _subCategoryList!.add(model);
                }
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {
      _subCategoryList = [];
    }
    update();
  }

  Future<void> getCampaignBasedCategoryList(String campaignID, bool isWithPagination) async {
    printLog("inside_campaign_based_category !");
    Response response = await categoryRepo.getItemsBasedOnCampaignId(campaignID: campaignID);

    if (response.body['response_code'] == 'default_200') {
      if(!isWithPagination){
        _campaignBasedCategoryList = [];
      }
      response.body['content']['data'].forEach((categoryTypesModel) {
        if(CategoryTypesModel.fromJson(categoryTypesModel).category != null){
          _campaignBasedCategoryList!.add(CategoryTypesModel.fromJson(categoryTypesModel).category!);
        }
      });
      _isLoading = false;
      Get.toNamed(RouteHelper.getCategoryRoute('fromCampaign',campaignID));
    } else {
      if(response.statusCode != 200){
        ApiChecker.checkApi(response);
      }else{
        customSnackBar('campaign_is_not_available_for_this_service'.tr, type: ToasterMessageType.info);
      }
    }
    update();
  }


  void toggleSearch() {
    _isSearching = !_isSearching!;
    _searchProductList = [];
    update();
  }
  void showBottomLoader() {
    _isLoading = true;
    update();
  }

}
