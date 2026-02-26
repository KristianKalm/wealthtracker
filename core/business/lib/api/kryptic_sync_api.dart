import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../crypto/pgp_encryption.dart';
import '../models/files_response.dart';
import 'kryptic_api_config.dart';
import 'kryptic_api_base.dart';

class KrypticSyncApi {
  String serverUrl;
  String username;
  String token;
  final KrypticApiConfig config;

  KrypticSyncApi(this.serverUrl, this.username, this.token, this.config);

  Future<Map<String, dynamic>> saveBytes(String folder, String file, Uint8List data, KrypticPgpEncryption pgp) async {
    var encryptedData = await pgp.encryptBytes(data);
    return _save(folder, file, encryptedData);
  }

  Future<Map<String, dynamic>> saveFile(String folder, String file, String data, KrypticPgpEncryption pgp) async {
    var encryptedData = await pgp.encrypt(data);
    return _save(folder, file, encryptedData);
  }

  Future<Map<String, dynamic>> _save(String folder, String file, String encryptedData) {
    return safeApiCall(
      () => http.post(
        Uri.parse('${serverUrl}file/${folder}/${file}'),
        headers: authHeaders(config, username, token, contentType: 'text/plain'),
        body: encryptedData,
      ),
      (response) {
        if (response.statusCode == 200) {
          return {"detail": "success"};
        }
        return <String, dynamic>{};
      },
      <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> saveFiles(String folder, List<FileData> files) {
    return safeApiCall(
      () => http.post(
        Uri.parse('${serverUrl}files/$folder'),
        headers: authHeaders(config, username, token),
        body: json.encode(files.map((f) => f.toJson()).toList()),
      ),
      (response) {
        if (response.statusCode == 200) return {"detail": "success"};
        return <String, dynamic>{};
      },
      <String, dynamic>{},
    );
  }

  Future<String?> loadData(String folder, String file, KrypticPgpEncryption pgp) async {
    final response = await _load(folder, file, pgp);
    if (response != null) {
      var decrypted = await pgp.decrypt(response);
      return decrypted;
    } else {
      return null;
    }
  }

  Future<Uint8List?> loadBytes(String folder, String file, KrypticPgpEncryption pgp) async {
    final response = await _load(folder, file, pgp);
    if (response != null) {
      var decrypted = await pgp.decryptBytes(response);
      return decrypted;
    } else {
      return null;
    }
  }

  Future<String?> _load(String folder, String file, KrypticPgpEncryption pgp) {
    return safeApiCall<String?>(
      () => http.get(
        Uri.parse('${serverUrl}file/${folder}/${file}'),
        headers: authHeaders(config, username, token, contentType: 'text/plain'),
      ),
      (response) {
        if (response.statusCode == 200) {
          return response.body;
        }
        return null;
      },
      null,
    );
  }

  Future<FilesResponse?> loadFilesPage(String folder, {int start = 0, int limit = 100, int? newerThan}) {
    var url = '${serverUrl}files/$folder?start=$start&limit=$limit';
    if (newerThan != null) {
      url += '&newer_than=$newerThan';
    }
    return safeApiCall<FilesResponse?>(
      () => http.get(Uri.parse(url), headers: authHeaders(config, username, token, contentType: 'text/plain')),
      (response) {
        if (response.statusCode == 200) {
          return FilesResponse.fromJson(json.decode(response.body));
        }
        return null;
      },
      null,
    );
  }

  Future<Map<String, dynamic>?> getUsage() {
    return safeApiCall<Map<String, dynamic>?>(
      () => http.get(Uri.parse('${serverUrl}usage'), headers: authHeaders(config, username, token)),
      (response) {
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
        return null;
      },
      null,
    );
  }

  Future<List<FileData>> loadAllFiles(String folder, {int batchSize = 100, int? newerThan}) async {
    List<FileData> allFiles = [];
    int start = 0;
    bool hasMore = true;

    while (hasMore) {
      final response = await loadFilesPage(folder, start: start, limit: batchSize, newerThan: newerThan);
      if (response == null) {
        break;
      }

      allFiles.addAll(response.files);
      hasMore = response.hasMore;
      start += response.files.length;
    }

    return allFiles;
  }
}
