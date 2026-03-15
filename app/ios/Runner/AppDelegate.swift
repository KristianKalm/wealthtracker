import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    clearKeychainOnFreshInstall()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func clearKeychainOnFreshInstall() {
    let initializedKey = "dev.kryptic.keychain_initialized"
    guard !UserDefaults.standard.bool(forKey: initializedKey) else { return }
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String]
    SecItemDelete(query as CFDictionary)
    UserDefaults.standard.set(true, forKey: initializedKey)
  }
}
