import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/common/repo/data_sync_repo.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class ServiceRepo extends DataSyncRepo {
  ServiceRepo({required super.apiClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getAllServiceList<T>({int offset = 1, required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.allServiceUri}?limit=10&offset=$offset', source);
  }

  Future<ApiResponseModel<T>> getPopularServiceList<T>({int offset = 1, required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.popularServiceUri}?limit=10&offset=$offset', source);
  }

  Future<ApiResponseModel<T>> getTrendingServiceList<T>({int offset = 1, required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.trendingServiceUri}?limit=10&offset=$offset', source);
  }

  Future<ApiResponseModel<T>> getRecommendedServiceList<T>({int offset = 1, required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.recommendedServiceUri}?limit=10&offset=$offset', source);
  }

  Future<ApiResponseModel<T>> getRecentlyViewedServiceList<T>({int offset = 1, required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.recentlyViewedServiceUri}?limit=10&offset=$offset', source);
  }

  Future<ApiResponseModel<T>> getFeatheredCategoryServiceList<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.featheredCategoryUri, source);
  }

  Future<Response> getServiceListBasedOnSubCategory({required String subCategoryID, int offset = 1}) async {
    return await apiClient.getData('${AppConstants.serviceBasedOnSubCategory}$subCategoryID?limit=10&offset=$offset');
  }

  Future<Response> getItemsBasedOnCampaignId({required String campaignID}) async {
    return await apiClient.getData('${AppConstants.itemsBasedOnCampaignId}$campaignID&limit=100&offset=1');
  }

  Future<Response> getRecommendedSearchList() async {
    return await apiClient.getData(AppConstants.recommendedSearchUri);
  }

  Future<Response> updateIsFavoriteStatus({required String serviceId}) async {
    return await apiClient.postData(AppConstants.updateIsFavoriteStatusUri, {'service_id': serviceId});
  }

  Future<Response> getOffersList(int offset) async {
    return await apiClient.getData('${AppConstants.offerListUri}?limit=10&offset=$offset');
  }
}
