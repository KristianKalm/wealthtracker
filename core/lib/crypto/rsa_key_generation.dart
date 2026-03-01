import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;

String generateMnemonic() => bip39.generateMnemonic(strength: 256);

pc.AsymmetricKeyPair<pc.PublicKey, pc.PrivateKey> generateDeterministicRSA(
  String mnemonic, {
  int bits = 2048,
}) {
  final seed = bip39.mnemonicToSeed(mnemonic);
  final seedHash = sha256.convert(seed).bytes;
  final secureRandom = pc.FortunaRandom()
    ..seed(pc.KeyParameter(Uint8List.fromList(seedHash)));
  final keyGen = pc.RSAKeyGenerator()
    ..init(
      pc.ParametersWithRandom(
        pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), bits, 32),
        secureRandom,
      ),
    );
  return keyGen.generateKeyPair();
}
