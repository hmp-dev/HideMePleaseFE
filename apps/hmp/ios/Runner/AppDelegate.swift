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

    // 앱 시작 시 이전 세션의 stale Live Activity 정리
    if #available(iOS 16.1, *) {
      print("🔵 [AppDelegate] Cleaning up stale Live Activities on app launch...")
      CheckInLiveActivityManager.shared.endAllActivities()
    }

    setupLiveActivityChannel()

    // Workmanager tasks are registered automatically by the Flutter plugin
    // No need to manually register them here

    // Enable background fetch for periodic tasks
    UIApplication.shared.setMinimumBackgroundFetchInterval(
      TimeInterval(60 * 15) // 15 minutes
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 앱 종료 시 Live Activity 정리
  override func applicationWillTerminate(_ application: UIApplication) {
    print("🔴 [AppDelegate] Application will terminate - ending Live Activity")
    if #available(iOS 16.1, *) {
      CheckInLiveActivityManager.shared.endLiveActivity()
    }
    super.applicationWillTerminate(application)
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
                let spaceId = args["spaceId"] as? String,
                let currentMembers = args["currentMembers"] as? Int,
                let requiredMembers = args["requiredMembers"] as? Int,
                let checkedInAt = args["checkedInAt"] as? String else {
            print("❌ [Flutter Channel] Invalid arguments")
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                 message: "Missing required arguments",
                                 details: nil))
            return
          }

          print("📱 [Flutter Channel] Starting Live Activity with spaceName: \(spaceName), spaceId: \(spaceId)")
          CheckInLiveActivityManager.shared.startLiveActivity(
            spaceName: spaceName,
            spaceId: spaceId,
            currentMembers: currentMembers,
            requiredMembers: requiredMembers,
            checkedInAt: checkedInAt,
            channel: channel
          ) { pushToken in
            // Push Token을 Flutter로 반환
            print("📱 [Flutter Channel] Returning Push Token: \(pushToken ?? "nil")")
            result(pushToken)
          }

        case "updateCheckInActivity":
          print("📱 [Flutter Channel] Processing updateCheckInActivity")
          guard let args = call.arguments as? [String: Any],
                let groupProgress = args["groupProgress"] as? String,
                let currentMembers = args["currentMembers"] as? Int,
                let requiredMembers = args["requiredMembers"] as? Int,
                let checkedInAt = args["checkedInAt"] as? String,
                let elapsedMinutes = args["elapsedMinutes"] as? Int,
                let isCompleted = args["isCompleted"] as? Bool else {
            print("❌ [Flutter Channel] Invalid arguments for update")
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                 message: "Missing required arguments",
                                 details: nil))
            return
          }

          let bonusPoints = args["bonusPoints"] as? Int

          CheckInLiveActivityManager.shared.updateLiveActivity(
            groupProgress: groupProgress,
            currentMembers: currentMembers,
            requiredMembers: requiredMembers,
            checkedInAt: checkedInAt,
            elapsedMinutes: elapsedMinutes,
            isCompleted: isCompleted,
            bonusPoints: bonusPoints
          )
          result(true)

        case "endCheckInActivity":
          CheckInLiveActivityManager.shared.endLiveActivity()
          result(true)

        case "endAllActivities":
          print("📱 [Flutter Channel] Processing endAllActivities")
          CheckInLiveActivityManager.shared.endAllActivities()
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
