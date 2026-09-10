import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:demandium/utils/app_constants.dart';
import 'package:demandium/feature/address/model/address_model.dart';
import 'package:demandium/common/models/error_response.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class ApiClient extends GetxService {
  final String? appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    AddressModel? addressModel;
    try {
      if (sharedPreferences.getString(AppConstants.userAddress) != null) {
        addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('');
      }
    }
    updateHeader(
      token,
      addressModel?.zoneId,
      sharedPreferences.getString(AppConstants.languageCode),
      sharedPreferences.getString(AppConstants.guestId),
    );
  }

  void updateHeader(String? token, String? zoneId, String? languageCode, String? guestId) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      AppConstants.localizationKey: languageCode ?? AppConstants.languages[0].languageCode!,
      AppConstants.zoneId: zoneId ?? '',
      AppConstants.guestId: guestId ?? '',
    };
  }

  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri');
      http.Response response = await http.get(
        Uri.parse(appBaseUrl! + uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String? uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri');
      http.Response response = await http.post(
        Uri.parse(appBaseUrl! + uri!),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String? uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      http.Response response = await http.put(
        Uri.parse(appBaseUrl! + uri!),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String? uri, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl! + uri!),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
    String? uri,
    Map<String, String> body,
    List<MultipartBody>? multipartBody, {
    Map<String, String>? headers,
  }) async {
    debugPrint('====> API Call: $uri');
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl! + uri!));
    request.headers.addAll(headers ?? _mainHeaders);

    if (multipartBody != null) {
      for (MultipartBody multipart in multipartBody) {
        File file = File(multipart.file.path);
        request.files.add(http.MultipartFile(
          multipart.key!,
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      }
    }

    request.fields.addAll(body);
    http.Response response = await http.Response.fromStream(await request.send());
    return handleResponse(response, uri);
  }

  Future<Response> postMultipartDataConversation(
    String? uri,
    Map<String, String> body,
    List<MultipartBody>? multipartBody, {
    Map<String, String>? headers,
    List<PlatformFile>? otherFile,
  }) async {
    debugPrint('====> API Call: $uri');
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl! + uri!));
    request.headers.addAll(headers ?? _mainHeaders);

    if (otherFile != null && otherFile.isNotEmpty) {
      for (PlatformFile platformFile in otherFile) {
        request.files.add(http.MultipartFile(
          'files[${otherFile.indexOf(platformFile)}]',
          platformFile.readStream!,
          platformFile.size,
          filename: basename(platformFile.name),
        ));
      }
    }

    if (multipartBody != null) {
      for (MultipartBody multipart in multipartBody) {
        File file = File(multipart.file.path);
        request.files.add(http.MultipartFile(
          multipart.key!,
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      }
    }

    request.fields.addAll(body);
    http.Response response = await http.Response.fromStream(await request.send());
    return handleResponse(response, uri);
  }

  Response handleResponse(http.Response response, String? uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('');
      }
    }
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
        headers: response.request!.headers,
        method: response.request!.method,
        url: response.request!.url,
      ),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 && response0.body != null && response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.errors![0].message,
        );
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: response0.body['message'],
        );
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    debugPrint('====> API Response: [${response0.statusCode}] $uri');
    return response0;
  }
}

class MultipartBody {
  String? key;
  XFile file;

  MultipartBody(this.key, this.file);
}
