import Flutter
import UIKit

public class EspSoftapProvisioningPlugin: NSObject, FlutterPlugin {
  private var cryptoAES: CryptoAES?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "esp_softap_provisioning", binaryMessenger: registrar.messenger())
    let instance = EspSoftapProvisioningPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      guard let args = call.arguments as? [String: Any],
        let key = args["key"] as? FlutterStandardTypedData,
        let iv = args["iv"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "invalid_arguments", message: "init expects 'key' and 'iv' byte arrays", details: nil))
        return
      }
      cryptoAES = CryptoAES(key: key.data, iv: iv.data)
      result(true)
    case "crypt":
      guard let args = call.arguments as? [String: Any],
        let data = args["data"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "invalid_arguments", message: "crypt expects a 'data' byte array", details: nil))
        return
      }
      guard let cryptoAES else {
        result(FlutterError(code: "not_initialized", message: "crypt was called before init", details: nil))
        return
      }
      guard let encrypted = cryptoAES.encrypt(data: data.data) else {
        result(FlutterError(code: "crypt_failed", message: "AES-CTR encryption failed; check the key and IV passed to init", details: nil))
        return
      }
      result(FlutterStandardTypedData(bytes: encrypted))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
