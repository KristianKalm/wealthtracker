import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


Future<Map<String, String>> encryptText(String text, String password) async {
  final random = Random.secure();
  final salt = List<int>.generate(16, (_) => random.nextInt(256));
  final ivBytes = List<int>.generate(12, (_) => random.nextInt(256));
  final key = _deriveKey(password, Uint8List.fromList(salt));
  final iv = encrypt.IV(Uint8List.fromList(ivBytes));
  final ec = encrypt.Encrypter(encrypt.AES(
    encrypt.Key(Uint8List.fromList(key)),
    mode: encrypt.AESMode.gcm,
  ));
  final encrypted = ec.encrypt(text, iv: iv);
  return {
    'ciphertext': base64Encode(encrypted.bytes),
    'salt': base64Encode(salt),
    'iv': base64Encode(ivBytes),
  };
}

Uint8List _deriveKey(String password, Uint8List salt, {int iterations = 10000}) {
  final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(salt, iterations, 32));
  return pbkdf2.process(utf8.encode(password));
}

String decryptText({
  required String ciphertext,
  required String salt,
  required String iv,
  required String password,
}) {
  final saltBytes = base64Decode(salt);
  final ivBytes = base64Decode(iv);
  final ciphertextBytes = base64Decode(ciphertext);
  final key = _deriveKey(password, saltBytes);
  final ivObj = encrypt.IV(ivBytes);
  final ec = encrypt.Encrypter(encrypt.AES(
    encrypt.Key(Uint8List.fromList(key)),
    mode: encrypt.AESMode.gcm,
  ));
  final encryptedData = encrypt.Encrypted(ciphertextBytes);
  final mnemonic = ec.decrypt(encryptedData, iv: ivObj);
  return mnemonic;
}
