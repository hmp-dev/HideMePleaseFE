import Foundation
import ActivityKit
import Flutter
import WidgetKit

@available(iOS 16.1, *)
class CheckInLiveActivityManager: NSObject {
    static let shared = CheckInLiveActivityManager()
    
    private var currentActivity: Activity<CheckInActivityAttributes>?
    private var updateTimer: Timer?
    
    func startLiveActivity(spaceName: String, currentUsers: Int, remainingUsers: Int, channel: FlutterMethodChannel) {
        print("🔵 [LiveActivity] Starting Live Activity...")
        print("🔵 [LiveActivity] Space Name: \(spaceName)")
        print("🔵 [LiveActivity] Current Users: \(currentUsers)")
        print("🔵 [LiveActivity] Remaining Users: \(remainingUsers)")
        
        // 권한 체크 (디버그를 위해 일시적으로 경고만 표시)
        let authInfo = ActivityAuthorizationInfo()
        print("🔵 [LiveActivity] Activities Enabled: \(authInfo.areActivitiesEnabled)")
        if #available(iOS 16.2, *) {
            print("🔵 [LiveActivity] Frequent Push Enabled: \(authInfo.frequentPushesEnabled)")
        }
        
        if !authInfo.areActivitiesEnabled {
            print("⚠️ [LiveActivity] Live Activities are not enabled in settings!")
            channel.invokeMethod("liveActivityError", arguments: "Live Activities are not enabled")
            // 디버그를 위해 계속 진행
            // return
        }
        
        let attributes = CheckInActivityAttributes(
            spaceName: spaceName
        )
        
        let initialState = CheckInActivityAttributes.ContentState(
            currentUsers: currentUsers,
            remainingUsers: remainingUsers
        )
        
        print("🔵 [LiveActivity] Attributes created, requesting activity...")
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            
            print("✅ [LiveActivity] Activity created successfully!")
            print("✅ [LiveActivity] Activity ID: \(currentActivity?.id ?? "nil")")
            
            channel.invokeMethod("liveActivityStarted", arguments: currentActivity?.id)
            
            // 1분 후 업데이트
            updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { _ in
                print("🔵 [LiveActivity] 1분 경과 - Live Activity 업데이트 중...")
                self.updateLiveActivity(currentUsers: currentUsers + 1, remainingUsers: max(0, remainingUsers - 1))
            }
            
            // 3분 후 자동 종료
            Timer.scheduledTimer(withTimeInterval: 180.0, repeats: false) { _ in
                print("🔵 [LiveActivity] 3분 경과 - Live Activity 자동 종료")
                self.endLiveActivity()
            }
        } catch {
            print("❌ [LiveActivity] Failed to create activity: \(error)")
            print("❌ [LiveActivity] Error details: \(error.localizedDescription)")
            channel.invokeMethod("liveActivityError", arguments: error.localizedDescription)
        }
    }
    
    func updateLiveActivity(currentUsers: Int, remainingUsers: Int) {
        guard let activity = currentActivity else { 
            print("⚠️ [LiveActivity] No current activity to update")
            return 
        }
        
        print("🔵 [LiveActivity] Updating Live Activity...")
        print("🔵 [LiveActivity] New Current Users: \(currentUsers)")
        print("🔵 [LiveActivity] New Remaining Users: \(remainingUsers)")
        
        let updatedState = CheckInActivityAttributes.ContentState(
            currentUsers: currentUsers,
            remainingUsers: remainingUsers
        )
        
        Task {
            await activity.update(using: updatedState)
            print("✅ [LiveActivity] Activity updated successfully!")
        }
    }
    
    func endLiveActivity() {
        print("🔵 [LiveActivity] Ending Live Activity...")
        guard let activity = currentActivity else { 
            print("⚠️ [LiveActivity] No current activity to end")
            return 
        }
        
        updateTimer?.invalidate()
        updateTimer = nil
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
            print("✅ [LiveActivity] Activity ended")
        }
        
        currentActivity = nil
    }
    
    // 타이머 관련 메서드 제거됨 - Live Activity는 정적 표시만 지원
}