import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openpgp/openpgp.dart';

import '../util/logger.dart';
import 'kryptic_api_config.dart';
import 'kryptic_api_base.dart';

const _tag = 'AuthApi';

class KrypticAuthApi {
  String serverUrl;
  final KrypticApiConfig config;

  KrypticAuthApi(this.serverUrl, this.config);

  Future<double?> getVersion() {
    Logger.debug(_tag, 'getVersion() GET ${serverUrl}info');
    return safeApiCall<double?>(
      () => http.get(Uri.parse('${serverUrl}info')),
      (response) {
        Logger.debug(_tag, 'getVersion() HTTP ${response.statusCode}');
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          final v = json['conf']['api_version'];
          Logger.debug(_tag, 'getVersion() api_version=$v');
          return v;
        }
        Logger.warn(_tag, 'getVersion() unexpected status ${response.statusCode}');
        return 0.0;
      },
      0.0,
    );
  }

  Future<Map<String, String>> getCaptcha() {
    Logger.debug(_tag, 'getCaptcha() GET ${serverUrl}register');
    return safeApiCall<Map<String, String>>(
      () => http.get(Uri.parse('${serverUrl}register'), headers: {'xApp': config.appName}),
      (response) {
        Logger.debug(_tag, 'getCaptcha() HTTP ${response.statusCode}');
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          final id = json['captcha_id']?.toString() ?? '';
          final img = json['captcha_image']?.toString() ?? '';
          Logger.debug(_tag, 'getCaptcha() received captchaId=$id imageLength=${img.length}');
          return {'captcha_id': id, 'captcha_image': img};
        }
        Logger.warn(_tag, 'getCaptcha() unexpected status ${response.statusCode} body=${response.body}');
        return <String, String>{};
      },
      <String, String>{},
    );
  }

  Future<Map<String, String>> register(
    String username,
    String password,
    Map<String, String> encryptedSeed,
    String publicKey,
    Map<String, String> encryptedPrivateKey,
    String tokenName,
    String captchaId,
    String captchaText,
  ) async {
    Logger.info(_tag, 'register() POST ${serverUrl}register username="$username" publicKeyLength=${publicKey.length}');
    var userHash = SHA1(config.userSalt + username);
    var passHash = SHA512(config.passSalt + password);
    Logger.debug(_tag, 'register() hashing done, encrypting token name...');
    var encryptedTokenName = await OpenPGP.encrypt(tokenName, publicKey);
    Logger.debug(_tag, 'register() token name encrypted, sending request...');
    final Map<String, dynamic> data = {
      "username": userHash,
      "password": passHash,
      "seed": encryptedSeed,
      "public_key": publicKey,
      "private_key": encryptedPrivateKey,
      "token_name": encryptedTokenName,
      "captcha_id": captchaId,
      "captcha_text": captchaText,
    };
    return safeApiCall(
      () => http.post(
        Uri.parse('${serverUrl}register'),
        headers: {'xApp': config.appName, 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ),
      (response) {
        Logger.debug(_tag, 'register() HTTP ${response.statusCode} bodyLength=${response.body.length}');
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          var token = json["token"].toString();
          var tokenId = json["token_id"]?.toString() ?? "";
          Logger.info(_tag, 'register() success: tokenId=$tokenId');
          return {"token": token, "token_id": tokenId};
        }
        if (response.statusCode >= 400 && response.statusCode < 500) {
          try {
            var json = jsonDecode(response.body);
            var detail = json["message"]?.toString() ?? "";
            Logger.error(_tag, 'register() client error ${response.statusCode}: $detail');
            return {"error": detail};
          } catch (_) {}
        }
        Logger.error(_tag, 'register() unexpected status ${response.statusCode} body=${response.body}');
        return <String, String>{};
      },
      <String, String>{},
    );
  }

  Future<Map<String, dynamic>> login(String username, String password, String? pin, String tokenName) async {
    Logger.info(_tag, 'login() POST ${serverUrl}login username="$username" hasPin=${pin != null && pin.isNotEmpty}');
    String timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    var userHash = SHA1(config.userSalt + username);
    var passHash = SHA512(timestamp + SHA512(config.passSalt + password));
    Logger.debug(_tag, 'login() hashes computed, sending request...');
    final Map<String, String> data = {"username": userHash, "password": passHash, "timestamp": timestamp};
    if (pin != null && pin.isNotEmpty) {
      data["pin"] = pin;
    }
    final result = await safeApiCall(
      () => http.post(Uri.parse('${serverUrl}login'), headers: {'xApp': config.appName, 'Content-Type': 'application/json'}, body: jsonEncode(data)),
      (response) {
        Logger.debug(_tag, 'login() HTTP ${response.statusCode} bodyLength=${response.body.length}');
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          var token = json["token"].toString();
          var tokenId = json["token_id"]?.toString() ?? "";
          var encryptedSeed = json["seed"];
          var encryptedPrivateKey = json["private_key"];
          var publicKey = json["public_key"].toString();
          Logger.info(_tag, 'login() 200 OK: tokenId=$tokenId publicKeyLength=${publicKey.length} '
              'seedKeys=${encryptedSeed is Map ? encryptedSeed.keys.toList() : null} '
              'privateKeyKeys=${encryptedPrivateKey is Map ? encryptedPrivateKey.keys.toList() : null}');
          return {"seed": encryptedSeed, "private_key": encryptedPrivateKey, "public_key": publicKey, "token": token, "token_id": tokenId};
        }
        if (response.statusCode == 403) {
          Logger.info(_tag, 'login() 403 OTP required');
          return {"otp_required": ""};
        }
        if (response.statusCode >= 400 && response.statusCode < 500) {
          try {
            var json = jsonDecode(response.body);
            var detail = json["message"]?.toString() ?? "";
            Logger.error(_tag, 'login() client error ${response.statusCode}: $detail');
            return {"error": detail};
          } catch (_) {}
        }
        Logger.error(_tag, 'login() unexpected status ${response.statusCode} body=${response.body}');
        return <String, dynamic>{};
      },
      <String, dynamic>{},
    );

    if (result.isNotEmpty && tokenName.isNotEmpty) {
      Logger.debug(_tag, 'login() updating token name...');
      try {
        var publicKey = result["public_key"].toString();
        var token = result["token"].toString();
        var encryptedTokenName = await OpenPGP.encrypt(tokenName, publicKey);
        final nameResponse = await http.put(
          Uri.parse('${serverUrl}token/name'),
          headers: authHeaders(config, username, token, contentType: 'text/plain'),
          body: encryptedTokenName,
        );
        Logger.debug(_tag, 'login() token name update HTTP ${nameResponse.statusCode}');
      } catch (e) {
        Logger.warn(_tag, 'login() token name update failed (non-critical): $e');
      }
    }

    Logger.info(_tag, 'login() returning result keys: ${result.keys.toList()}');
    return result;
  }
}
