import 'dart:convert';
import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';


class DataSyncHelper {
  /// Generic method to fetch data from local and remote sources
  static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<CacheResponseData>> Function() fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic, DataSourceEnum source) onResponse,
  }) async {

    try {
      final localResponse = await fetchFromLocal();
      if (localResponse.isSuccess && localResponse.response?.response != null) {
        try {
          onResponse(jsonDecode(localResponse.response!.response), DataSourceEnum.local);
        } catch (_) {}
      }
    } catch (_) {}

    try {
      final clientResponse = await fetchFromClient();
      if (clientResponse.isSuccess && clientResponse.response?.statusCode == 200) {
        try {
          onResponse(clientResponse.response?.body, DataSourceEnum.client);
        } catch (_) {}
      } else if (clientResponse.response?.statusCode != 429) {
        ApiChecker.checkApi(Response(
          body: clientResponse.response?.body,
          statusCode: clientResponse.response?.statusCode,
          statusText: clientResponse.response?.statusText,
        ));
      }
    } catch (_) {}

  }
}


