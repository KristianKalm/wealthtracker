import 'dart:convert';
import 'dart:typed_data';

import 'package:openpgp/openpgp.dart';

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
