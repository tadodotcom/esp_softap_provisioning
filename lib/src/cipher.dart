import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart';

class Cipher {
  Encrypter enc;
  IV iv;
  Crypto(Uint8List key, Uint8List iv)
  {
    this.iv = IV(iv);
    this.enc = Encrypter(AES(Key(key), mode: AESMode.ctr, padding: null));
  }

  Future<Uint8List> encrypt(Uint8List input) async{
    return this.enc.encryptBytes(input=input, iv: this.iv).bytes;
  }

  Future <Uint8List> decrypt(Uint8List input) async{
    final encrypted = Encrypted(input);
    return this.enc.decryptBytes(encrypted, iv: this.iv);
  }
}
