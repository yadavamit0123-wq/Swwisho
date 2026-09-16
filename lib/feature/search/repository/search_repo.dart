import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class SearchRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SearchRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getSearchData({required String query,required offset,String? sortBy, String? sortByType, double? minPrice, double ? maxPrice, String? rating, List<String>? categoryIdes }) async {

    Map<String, dynamic> data = {
      "string": query,
      "sort_by" : sortBy,
      "sort_by_type": sortByType,
      "min_price": minPrice,
      "max_price": maxPrice,
      "rating" : rating,
    };
    if(categoryIdes !=null && categoryIdes.isNotEmpty){
      data.addAll({
        "category_ids" : categoryIdes
      });
    }
    try {
      final response = await apiClient.postData("${AppConstants.searchUri}?limit=10&offset=$offset", data);
      if (response.statusCode == 200) {
        return response;
      }
    } catch (_) {}
    return await apiClient.getData('${AppConstants.allServiceUri}?limit=100&offset=$offset');
  }

  Future<Response> getSearchSuggestion({String? query}) async {

    return apiClient.getData("${AppConstants.searchSuggestion}?string=${query?.trim()}");
  }

  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await sharedPreferences.setStringList(AppConstants.searchHistory, searchHistories);
  }

  List<String> getSearchAddress() {
    return sharedPreferences.getStringList(AppConstants.searchHistory) ?? [];
  }

}
