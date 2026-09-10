import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/common/repo/data_sync_repo.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CategoryRepo extends DataSyncRepo {
  CategoryRepo({required super.apiClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source, int offset = 1}) async {
    return await fetchData<T>('${AppConstants.categoryUrl}&limit=100&offset=$offset', source);
  }

  Future<Response> getSubCategoryList(String categoryID) async {
    return await apiClient.getData('${AppConstants.subCategoryUri}$categoryID');
  }

  Future<Response> getItemsBasedOnCampaignId({required String campaignID}) async {
    return await apiClient.getData('${AppConstants.itemsBasedOnCampaignId}$campaignID&limit=100&offset=1');
  }
}
