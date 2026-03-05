import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'kryptic_api_config.dart';

void Function()? onUnauthorized;
void Function()? onStorageFull;

String SHA512(String value) {
  return sha512.convert(utf8.encode(value)).toString();
}

String SHA1(String value) {
  return sha1.convert(utf8.encode(value)).toString();
}

Map<String, String> authHeaders(KrypticApiConfig config, String username, String token, {String contentType = 'application/json'}) {
  String timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
  var userHash = SHA1(config.userSalt + username);
  var tokenHash = SHA512(timestamp + token);
  return {
    'xApp': config.appName,
    'xAuthToken': tokenHash,
    'xAuthUser': userHash,
    'xTimestamp': timestamp,
    'Content-Type': contentType,
  };
}

Future<T> safeApiCall<T>(Future<http.Response> Function() call, T Function(http.Response response) onResponse, T fallback) async {
  try {
    final response = await call();
    print('[safeApiCall] status=${response.statusCode}');
    if (response.statusCode == 401) {
      onUnauthorized?.call();
      return fallback;
    }
    if (response.statusCode == 413) {
      print('[safeApiCall] 413 received — onStorageFull=${onStorageFull != null ? "set" : "null"}');
      onStorageFull?.call();
      return fallback;
    }
    return onResponse(response);
  } catch (e) {
    print('[safeApiCall] exception: $e');
    return fallback;
  }
}
