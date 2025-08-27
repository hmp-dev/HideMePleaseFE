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
      print("📱 [Flutter Channel] Received method call: \(call.method)")
      if #available(iOS 16.1, *) {
        switch call.method {
        case "startCheckInActivity":
          print("📱 [Flutter Channel] Processing startCheckInActivity")
          guard let args = call.arguments as? [String: Any],
                let spaceName = args["spaceName"] as? String,
                let currentUsers = args["currentUsers"] as? Int,
                let remainingUsers = args["remainingUsers"] as? Int else {
            print("❌ [Flutter Channel] Invalid arguments")
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                 message: "Missing required arguments",
                                 details: nil))
            return
          }
          
          print("📱 [Flutter Channel] Starting Live Activity with spaceName: \(spaceName), currentUsers: \(currentUsers), remainingUsers: \(remainingUsers)")
          CheckInLiveActivityManager.shared.startLiveActivity(
            spaceName: spaceName,
            currentUsers: currentUsers,
            remainingUsers: remainingUsers,
            channel: channel
          )
          result(true)
          
        case "updateCheckInActivity":
          // 업데이트는 타이머에 의해 자동으로 처리됨
          print("📱 [Flutter Channel] Update called - handled by timer")
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
