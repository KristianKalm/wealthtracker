import 'dart:convert';

import 'package:http/http.dart' as http;

import 'kryptic_api_config.dart';
import 'kryptic_api_base.dart';

class KrypticSessionApi {
  String serverUrl;
  String username;
  String token;
  final KrypticApiConfig config;

  KrypticSessionApi(this.serverUrl, this.username, this.token, this.config);

  Future<Map<String, dynamic>> getTokens() {
    return safeApiCall(
      () => http.get(Uri.parse('${serverUrl}tokens'), headers: authHeaders(config, username, token)),
      (response) {
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        return <String, dynamic>{};
      },
      <String, dynamic>{},
    );
  }

  Future<Map<String, String>> getOta() {
    return safeApiCall(
      () => http.get(Uri.parse('${serverUrl}ota'), headers: authHeaders(config, username, token)),
      (response) {
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          return {'status': 'new', 'ota': json['ota'] as String};
        } else if (response.statusCode == 400) {
          return {'status': 'exists'};
        }
        return {'status': 'error'};
      },
      {'status': 'error'},
    );
  }

  Future<bool> deleteOta(String password) {
    var headers = authHeaders(config, username, token);
    var passHash = SHA512(headers['xTimestamp']! + SHA512(config.passSalt + password));
    return safeApiCall(
      () => http.delete(
        Uri.parse('${serverUrl}ota'),
        headers: headers,
        body: jsonEncode({'password': passHash, 'timestamp': headers['xTimestamp']}),
      ),
      (response) => response.statusCode == 200,
      false,
    );
  }

  Future<bool> confirmOta(String pin) {
    return safeApiCall(
      () => http.post(Uri.parse('${serverUrl}ota'), headers: authHeaders(config, username, token), body: jsonEncode({'pin': pin})),
      (response) => response.statusCode == 200,
      false,
    );
  }

  Future<bool> deleteAccount(String password) async {
    var headers = authHeaders(config, username, token);
    var passHash = SHA512(headers['xTimestamp']! + SHA512(config.passSalt + password));
    try {
      final response = await http.delete(
        Uri.parse('${serverUrl}account'),
        headers: headers,
        body: jsonEncode({'password': passHash, 'timestamp': headers['xTimestamp']}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword, Map<String, String> encryptedSeed, String publicKey) {
    var headers = authHeaders(config, username, token);
    var oldPassHash = SHA512(headers['xTimestamp']! + SHA512(config.passSalt + oldPassword));
    var newPassHash = SHA512(config.passSalt + newPassword);
    return safeApiCall(
      () => http.put(
        Uri.parse('${serverUrl}account'),
        headers: headers,
        body: jsonEncode({
          'old_password': oldPassHash,
          'timestamp': headers['xTimestamp'],
          'password': newPassHash,
          'public_key': publicKey,
          'seed': encryptedSeed,
        }),
      ),
      (response) => response.statusCode == 200,
      false,
    );
  }

  Future<bool> deleteToken(String tokenId) {
    return safeApiCall(
      () => http.delete(Uri.parse('${serverUrl}token'), headers: authHeaders(config, username, token), body: jsonEncode({"id": tokenId})),
      (response) => response.statusCode == 200,
      false,
    );
  }
}
