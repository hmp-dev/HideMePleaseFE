import UIKit
import Flutter
import GoogleMaps
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDJNUW4Havfk4EV9oD7wzpmOikhUw4HpKs")
    GeneratedPluginRegistrant.register(with: self)
    
    setupLiveActivityChannel()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupLiveActivityChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(name: "com.hidemeplease/live_activity",
                                        binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      if #available(iOS 16.1, *) {
        switch call.method {
        case "startCheckInActivity":
          guard let args = call.arguments as? [String: Any],
                let spaceName = args["spaceName"] as? String,
                let benefit = args["benefit"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                 message: "Missing required arguments",
                                 details: nil))
            return
          }
          
          CheckInLiveActivityManager.shared.startLiveActivity(
            spaceName: spaceName,
            benefit: benefit,
            channel: channel
          )
          result(true)
          
        case "updateCheckInActivity":
          guard let args = call.arguments as? [String: Any],
                let isConfirmed = args["isConfirmed"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                 message: "Missing required arguments",
                                 details: nil))
            return
          }
          
          CheckInLiveActivityManager.shared.updateLiveActivity(isConfirmed: isConfirmed)
          result(true)
          
        case "endCheckInActivity":
          CheckInLiveActivityManager.shared.endLiveActivity()
          result(true)
          
        default:
          result(FlutterMethodNotImplemented)
        }
      } else {
        result(FlutterError(code: "UNAVAILABLE",
                             message: "Live Activities require iOS 16.1+",
                             details: nil))
      }
    }
  }
}
