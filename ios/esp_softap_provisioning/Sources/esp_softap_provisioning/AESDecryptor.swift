//
//  AESDecryptor.swift
//  EspressifProvision
//
//  Created by Vikas Chandra on 15/05/19.
//  Copyright © 2019 Espressif. All rights reserved.
//
//  Ported from Objective-C to Swift so the plugin can be built as a single
//  Swift package target.
//

import CommonCrypto
import Foundation

/// AES-256 in CTR mode (big-endian counter) on top of CommonCrypto.
///
/// The cryptor is created once, so the counter carries on across
/// `cryptData(_:)` calls, the same as `Cipher.update` on Android.
final class AESDecryptor {
  private var cryptor: CCCryptorRef?

  init(key: Data, iv: Data) {
    // CCCryptorCreateWithMode reads kCCKeySizeAES256 bytes of the key and one
    // block of the IV, so reject shorter buffers instead of over-reading them.
    // `cryptData(_:)` returns nil when there is no cryptor.
    guard key.count == kCCKeySizeAES256, iv.count == kCCBlockSizeAES128 else {
      NSLog("CCCryptorArgument key.count: %d, iv.count: %d", key.count, iv.count)
      return
    }

    var cryptor: CCCryptorRef?
    let status = key.withUnsafeBytes { keyBytes in
      iv.withUnsafeBytes { ivBytes in
        CCCryptorCreateWithMode(
          CCOperation(kCCEncrypt), CCMode(kCCModeCTR), CCAlgorithm(kCCAlgorithmAES),
          CCPadding(ccNoPadding),
          ivBytes.baseAddress, keyBytes.baseAddress,
          kCCKeySizeAES256,
          nil, 0, 0,  // tweak (XTS mode only), tweak length, numRounds
          CCModeOptions(kCCModeOptionCTR_BE),
          &cryptor)
      }
    }
    if status == kCCSuccess {
      self.cryptor = cryptor
    } else {
      NSLog("CCCryptorCreateWithMode status: %d", status)
    }
  }

  deinit {
    if let cryptor {
      CCCryptorRelease(cryptor)
    }
  }

  func cryptData(_ dataIn: Data) -> Data? {
    guard let cryptor else {
      return nil
    }

    let dataOutLength = CCCryptorGetOutputLength(cryptor, dataIn.count, true)
    var dataOut = Data(count: dataOutLength)
    var dataOutMovedTotal = 0

    let status: CCCryptorStatus = dataOut.withUnsafeMutableBytes { dataOutBytes in
      dataIn.withUnsafeBytes { dataInBytes in
        var dataOutMoved = 0
        var status = CCCryptorUpdate(
          cryptor,
          dataInBytes.baseAddress, dataIn.count,
          dataOutBytes.baseAddress, dataOutLength,
          &dataOutMoved)
        guard status == kCCSuccess else {
          NSLog("CCCryptorUpdate status: %d", status)
          return status
        }
        dataOutMovedTotal += dataOutMoved

        status = CCCryptorFinal(
          cryptor,
          dataOutBytes.baseAddress?.advanced(by: dataOutMoved), dataOutLength - dataOutMoved,
          &dataOutMoved)
        guard status == kCCSuccess else {
          NSLog("CCCryptorFinal status: %d", status)
          return status
        }
        dataOutMovedTotal += dataOutMoved
        return status
      }
    }

    guard status == kCCSuccess else {
      // The counter state is unknown after a failure; drop the cryptor so
      // later calls fail too instead of producing a misaligned key stream.
      CCCryptorRelease(cryptor)
      self.cryptor = nil
      return nil
    }

    dataOut.count = dataOutMovedTotal
    return dataOut
  }
}
