import UIKit
import Flutter
import AppAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
  var currentAuthorizationFlow: OIDExternalUserAgentSession?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if let authFlow = currentAuthorizationFlow,
       authFlow.resumeExternalUserAgentFlow(with: url) {
      currentAuthorizationFlow = nil
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
