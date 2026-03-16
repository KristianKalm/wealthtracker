import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../crypto/pgp_encryption.dart';
import '../models/files_response.dart';
import '../util/logger.dart';
import 'kryptic_api_config.dart';
import 'kryptic_api_base.dart';

const _tag = 'SyncApi';

class KrypticSyncApi {
  String serverUrl;
  String username;
  String token;
  final KrypticApiConfig config;

  KrypticSyncApi(this.serverUrl, this.username, this.token, this.config);

  Future<Map<String, dynamic>> saveBytes(String folder, String file, Uint8List data, KrypticPgpEncryption pgp) async {
    Logger.debug(_tag, 'saveBytes() folder=$folder file=$file bytes=${data.length}');
    var encryptedData = await pgp.encryptBytes(data);
    final result = await _save(folder, file, encryptedData);
    Logger.debug(_tag, 'saveBytes() done: folder=$folder file=$file result=$result');
    return result;
  }

  Future<Map<String, dynamic>> saveFile(String folder, String file, String data, KrypticPgpEncryption pgp) async {
    Logger.debug(_tag, 'saveFile() folder=$folder file=$file plaintext length=${data.length}');
    var encryptedData = await pgp.encrypt(data);
    final result = await _save(folder, file, encryptedData);
    Logger.debug(_tag, 'saveFile() done: folder=$folder file=$file result=$result');
    return result;
  }

  Future<Map<String, dynamic>> _save(String folder, String file, String encryptedData) {
    Logger.debug(_tag, '_save() POST folder=$folder file=$file encrypted length=${encryptedData.length}');
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
    Logger.debug(_tag, 'loadData() folder=$folder file=$file');
    final response = await _load(folder, file, pgp);
    if (response != null) {
      Logger.debug(_tag, 'loadData() decrypting: ciphertext length=${response.length}');
      try {
        var decrypted = await pgp.decrypt(response);
        Logger.debug(_tag, 'loadData() decrypted OK: folder=$folder file=$file plaintext length=${decrypted.length}');
        return decrypted;
      } catch (e, st) {
        Logger.error(_tag, 'loadData() decrypt FAILED folder=$folder file=$file: $e\n$st');
        rethrow;
      }
    } else {
      Logger.debug(_tag, 'loadData() no data found: folder=$folder file=$file');
      return null;
    }
  }

  Future<Uint8List?> loadBytes(String folder, String file, KrypticPgpEncryption pgp) async {
    Logger.debug(_tag, 'loadBytes() folder=$folder file=$file');
    final response = await _load(folder, file, pgp);
    if (response != null) {
      Logger.debug(_tag, 'loadBytes() decrypting: base64 length=${response.length}');
      try {
        var decrypted = await pgp.decryptBytes(response);
        Logger.debug(_tag, 'loadBytes() decrypted OK: folder=$folder file=$file bytes=${decrypted.length}');
        return decrypted;
      } catch (e, st) {
        Logger.error(_tag, 'loadBytes() decrypt FAILED folder=$folder file=$file: $e\n$st');
        rethrow;
      }
    } else {
      Logger.debug(_tag, 'loadBytes() no data found: folder=$folder file=$file');
      return null;
    }
  }

  Future<String?> _load(String folder, String file, KrypticPgpEncryption pgp) {
    Logger.debug(_tag, '_load() GET folder=$folder file=$file');
    return safeApiCall<String?>(
      () => http.get(
        Uri.parse('${serverUrl}file/${folder}/${file}'),
        headers: authHeaders(config, username, token, contentType: 'text/plain'),
      ),
      (response) {
        Logger.debug(_tag, '_load() HTTP ${response.statusCode} folder=$folder file=$file '
            'body length=${response.body.length}');
        if (response.statusCode == 200) {
          return response.body;
        }
        Logger.warn(_tag, '_load() non-200 status=${response.statusCode} folder=$folder file=$file body=${response.body}');
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
