import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openpgp/openpgp.dart';

import 'kryptic_api_config.dart';
import 'kryptic_api_base.dart';

class KrypticAuthApi {
  String serverUrl;
  final KrypticApiConfig config;

  KrypticAuthApi(this.serverUrl, this.config);

  Future<double?> getVersion() {
    return safeApiCall<double?>(
      () => http.get(Uri.parse('${serverUrl}info')),
      (response) {
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          return json['conf']['api_version'];
        }
        return 0.0;
      },
      0.0,
    );
  }

  Future<Map<String, String>> getCaptcha() {
    return safeApiCall<Map<String, String>>(
      () => http.get(Uri.parse('${serverUrl}register'), headers: {'xApp': config.appName}),
      (response) {
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          return {
            'captcha_id': json['captcha_id']?.toString() ?? '',
            'captcha_image': json['captcha_image']?.toString() ?? '',
          };
        }
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
    var userHash = SHA1(config.userSalt + username);
    var passHash = SHA512(config.passSalt + password);
    var encryptedTokenName = await OpenPGP.encrypt(tokenName, publicKey);
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
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          var token = json["token"].toString();
          var tokenId = json["token_id"]?.toString() ?? "";
          return {"token": token, "token_id": tokenId};
        }
        if (response.statusCode >= 400 && response.statusCode < 500) {
          try {
            var json = jsonDecode(response.body);
            var detail = json["message"]?.toString() ?? "";
            return {"error": detail};
          } catch (_) {}
        }
        return <String, String>{};
      },
      <String, String>{},
    );
  }

  Future<Map<String, dynamic>> login(String username, String password, String? pin, String tokenName) async {
    String timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    var userHash = SHA1(config.userSalt + username);
    var passHash = SHA512(timestamp + SHA512(config.passSalt + password));
    final Map<String, String> data = {"username": userHash, "password": passHash, "timestamp": timestamp};
    if (pin != null && pin.isNotEmpty) {
      data["pin"] = pin;
    }
    final result = await safeApiCall(
      () => http.post(Uri.parse('${serverUrl}login'), headers: {'xApp': config.appName, 'Content-Type': 'application/json'}, body: jsonEncode(data)),
      (response) {
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          var token = json["token"].toString();
          var tokenId = json["token_id"]?.toString() ?? "";
          var encryptedSeed = json["seed"];
          var encryptedPrivateKey = json["private_key"];
          var publicKey = json["public_key"].toString();
          return {"seed": encryptedSeed, "private_key": encryptedPrivateKey, "public_key": publicKey, "token": token, "token_id": tokenId};
        }
        if (response.statusCode == 403) {
          return {"otp_required": ""};
        }
        if (response.statusCode >= 400 && response.statusCode < 500) {
          try {
            var json = jsonDecode(response.body);
            var detail = json["message"]?.toString() ?? "";
            return {"error": detail};
          } catch (_) {}
        }
        return <String, dynamic>{};
      },
      <String, dynamic>{},
    );

    if (result.isNotEmpty && tokenName.isNotEmpty) {
      try {
        var publicKey = result["public_key"].toString();
        var token = result["token"].toString();
        var encryptedTokenName = await OpenPGP.encrypt(tokenName, publicKey);
        await http.put(
          Uri.parse('${serverUrl}token/name'),
          headers: authHeaders(config, username, token, contentType: 'text/plain'),
          body: encryptedTokenName,
        );
      } catch (_) {}
    }

    return result;
  }
}
