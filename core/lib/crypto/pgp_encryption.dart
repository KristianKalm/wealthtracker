import 'dart:convert';
import 'dart:typed_data';

import 'package:openpgp/openpgp.dart';

import '../util/logger.dart';

const _tag = 'PGP';

Future<Map<String, String>> generatePGPKeys(String passphrase) async {
  Logger.info(_tag, 'Generating PGP key pair (RSA 2048)...');
  try {
    var keyOptions = KeyOptions()..rsaBits = 2048;
    var keyPair = await OpenPGP.generate(
      options: Options()
        ..name = ''
        ..email = ''
        ..passphrase = passphrase
        ..keyOptions = keyOptions,
    );
    Logger.info(_tag, 'Key pair generated successfully. '
        'publicKey length=${keyPair.publicKey.length}, '
        'privateKey length=${keyPair.privateKey.length}');
    return {'public': keyPair.publicKey, 'private': keyPair.privateKey};
  } catch (e, st) {
    Logger.error(_tag, 'Key generation failed: $e\n$st');
    return {};
  }
}

class KrypticPgpEncryption {
  final String privateKey;
  final String publicKey;
  final String passphrase;

  KrypticPgpEncryption({required this.privateKey, required this.publicKey, required this.passphrase});

  Future<String> encrypt(String string) async {
    Logger.debug(_tag, 'encrypt() called: plaintext length=${string.length}, '
        'publicKey length=${publicKey.length}');
    try {
      final result = await OpenPGP.encrypt(string, publicKey);
      Logger.debug(_tag, 'encrypt() success: ciphertext length=${result.length}');
      return result;
    } catch (e, st) {
      Logger.error(_tag, 'encrypt() FAILED: $e\n$st');
      rethrow;
    }
  }

  Future<String> decrypt(String encryptedString) async {
    Logger.debug(_tag, 'decrypt() called: ciphertext length=${encryptedString.length}, '
        'privateKey length=${privateKey.length}, '
        'passphrase length=${passphrase.length}');
    if (privateKey.isEmpty) {
      Logger.error(_tag, 'decrypt() ABORTED: privateKey is empty!');
      throw Exception('PGP privateKey is empty');
    }
    if (passphrase.isEmpty) {
      Logger.warn(_tag, 'decrypt() WARNING: passphrase is empty');
    }
    try {
      final result = await OpenPGP.decrypt(encryptedString, privateKey, passphrase);
      Logger.debug(_tag, 'decrypt() success: plaintext length=${result.length}');
      return result;
    } catch (e, st) {
      Logger.error(_tag, 'decrypt() FAILED: $e\n$st');
      rethrow;
    }
  }

  Future<String> encryptBytes(Uint8List bytes) async {
    Logger.debug(_tag, 'encryptBytes() called: bytes=${bytes.length}, '
        'publicKey length=${publicKey.length}');
    try {
      final encrypted = await OpenPGP.encryptBytes(bytes, publicKey);
      final encoded = base64Encode(encrypted);
      Logger.debug(_tag, 'encryptBytes() success: base64 length=${encoded.length}');
      return encoded;
    } catch (e, st) {
      Logger.error(_tag, 'encryptBytes() FAILED: $e\n$st');
      rethrow;
    }
  }

  Future<Uint8List> decryptBytes(String base64Encrypted) async {
    Logger.debug(_tag, 'decryptBytes() called: base64 length=${base64Encrypted.length}, '
        'privateKey length=${privateKey.length}, '
        'passphrase length=${passphrase.length}');
    if (privateKey.isEmpty) {
      Logger.error(_tag, 'decryptBytes() ABORTED: privateKey is empty!');
      throw Exception('PGP privateKey is empty');
    }
    try {
      final encryptedBytes = base64Decode(base64Encrypted);
      Logger.debug(_tag, 'decryptBytes() decoded base64: bytes=${encryptedBytes.length}');
      final decrypted = await OpenPGP.decryptBytes(encryptedBytes, privateKey, passphrase);
      final result = Uint8List.fromList(decrypted);
      Logger.debug(_tag, 'decryptBytes() success: decrypted bytes=${result.length}');
      return result;
    } catch (e, st) {
      Logger.error(_tag, 'decryptBytes() FAILED: $e\n$st');
      rethrow;
    }
  }
}
