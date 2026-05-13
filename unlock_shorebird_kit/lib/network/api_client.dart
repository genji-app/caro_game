import 'dart:convert';

import 'package:unlock_shorebird_kit/models/unlock_command_response.dart';
import 'package:unlock_shorebird_kit/network/config_loader.dart';
import 'package:unlock_shorebird_kit/network/plain_body_dio_transformer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static Future<Map<String, dynamic>> getConfig(String url) =>
      ConfigLoader.getConfig(url);

  /// Uses Dio with a plain-body transformer so malformed `Content-Type` does not trigger MIME warnings.
  static Future<UnlockCommandResponse> getUnlockCommandResponse({
    required String url,
  }) async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.transformer = PlainBodyDioTransformer();
    final Response<String> response = await dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );
    // final int? statusCode = response.statusCode;
    // if (statusCode != null &&
    //     (statusCode < 200 || statusCode >= 300)) {
    //   throw Exception('Unlock request failed: HTTP $statusCode');
    // }
    final String rawJson = (response.data ?? '').trim();
    debugPrint('Unlock command response: $rawJson');
    if (rawJson.isEmpty) {
      throw Exception('Empty unlock response body');
    }
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unlock response is not a JSON object');
    }
    return UnlockCommandResponse.fromJson(decoded);
  }
}
