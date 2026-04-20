import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_game_url_request.freezed.dart';
part 'get_game_url_request.g.dart';

/// Request model for POST /get-url endpoint
@freezed
sealed class GetGameUrlRequest with _$GetGameUrlRequest {
  const factory GetGameUrlRequest({
    required String providerId,
    required String productId,
    required String gameCode,
    String? lang,
    bool? isMobileLogin,
  }) = _GetGameUrlRequest;

  const GetGameUrlRequest._();

  factory GetGameUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$GetGameUrlRequestFromJson(json);

  /// Build JSON matching API spec (extra.lang, extra.isMobileLogin)
  Map<String, dynamic> toApiJson() {
    return {
      'providerId': providerId,
      'productId': productId,
      'gameCode': gameCode,
      if (lang != null || isMobileLogin != null)
        'extra': {
          if (lang != null) 'lang': lang,
          if (isMobileLogin != null) 'isMobileLogin': isMobileLogin,
        },
    };
  }
}
