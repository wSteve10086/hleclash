
import 'package:encrypt/encrypt.dart';

class AESUtil {
  static final key = Key.fromUtf8('fastflyfly@789.!');
  //
  static final iv = IV.fromLength(16);

  static String encryptAES(String plainText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptAES(String encryptedText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
    final decrypted = encrypter.decrypt(Encrypted.from64(encryptedText), iv: iv);
    return decrypted;
  }
}
