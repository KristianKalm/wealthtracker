import 'dart:convert';
import 'dart:developer' as Logger;
import 'dart:typed_data';

import 'package:openpgp/openpgp.dart';

Future<Map<String, String>> generatePGPKeys(String passphrase) async {
  try {
    var keyOptions = KeyOptions()..rsaBits = 2048;
    var keyPair = await OpenPGP.generate(
      options: Options()
        ..name = ''
        ..email = ''
        ..passphrase = passphrase
        ..keyOptions = keyOptions,
    );
    return {'public': keyPair.publicKey, 'private': keyPair.privateKey};
  } catch (e) {
    Logger.log('Error during key generation: $e');
    return {};
  }
}

class KrypticPgpEncryption {
  final String privateKey;
  final String publicKey;
  final String passphrase;

  KrypticPgpEncryption({required this.privateKey, required this.publicKey, required this.passphrase});

  Future<String> encrypt(String string) async {
    return await OpenPGP.encrypt(string, publicKey);
  }

  Future<String> decrypt(String encryptedString) async {
    return await OpenPGP.decrypt(encryptedString, privateKey, passphrase);
  }

  Future<String> encryptBytes(Uint8List bytes) async {
    final encrypted = await OpenPGP.encryptBytes(bytes, publicKey);
    return base64Encode(encrypted);
  }

  Future<Uint8List> decryptBytes(String base64Encrypted) async {
    final encryptedBytes = base64Decode(base64Encrypted);
    final decrypted = await OpenPGP.decryptBytes(encryptedBytes, privateKey, passphrase);
    return Uint8List.fromList(decrypted);
  }
}
