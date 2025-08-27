import Foundation
import ActivityKit
import Flutter
import WidgetKit

@available(iOS 16.1, *)
class CheckInLiveActivityManager: NSObject {
    static let shared = CheckInLiveActivityManager()
    
    private var currentActivity: Activity<CheckInActivityAttributes>?
    private var updateTimer: Timer?
    
    func startLiveActivity(spaceName: String, benefit: String, channel: FlutterMethodChannel) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            channel.invokeMethod("liveActivityError", arguments: "Live Activities are not enabled")
            return
        }
        
        let attributes = CheckInActivityAttributes(
            spaceName: spaceName,
            benefit: benefit,
            checkInTime: Date()
        )
        
        let initialState = CheckInActivityAttributes.ContentState(
            remainingTime: 300, // DEBUG: 5 minutes (300초), PRODUCTION: 10800 (3시간)
            isConfirmed: false
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            
            startTimer(channel: channel)
            
            channel.invokeMethod("liveActivityStarted", arguments: currentActivity?.id)
        } catch {
            channel.invokeMethod("liveActivityError", arguments: error.localizedDescription)
        }
    }
    
    func updateLiveActivity(isConfirmed: Bool) {
        guard let activity = currentActivity else { return }
        
        Task {
            let updatedState = CheckInActivityAttributes.ContentState(
                remainingTime: getRemainingTime(),
                isConfirmed: isConfirmed
            )
            
            await activity.update(using: updatedState)
        }
    }
    
    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        updateTimer?.invalidate()
        updateTimer = nil
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
        
        currentActivity = nil
    }
    
    private func startTimer(channel: FlutterMethodChannel) {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let activity = self.currentActivity else { return }
            
            let remainingTime = self.getRemainingTime()
            
            if remainingTime <= 0 {
                self.endLiveActivity()
                channel.invokeMethod("liveActivityExpired", arguments: nil)
            } else {
                Task {
                    let updatedState = CheckInActivityAttributes.ContentState(
                        remainingTime: remainingTime,
                        isConfirmed: activity.contentState.isConfirmed
                    )
                    
                    await activity.update(using: updatedState)
                }
            }
        }
    }
    
    private func getRemainingTime() -> Int {
        guard let activity = currentActivity else { return 0 }
        
        let elapsed = Date().timeIntervalSince(activity.attributes.checkInTime)
        let remaining = max(0, 300 - Int(elapsed)) // DEBUG: 300초 (5분), PRODUCTION: 10800 (3시간)
        
        return remaining
    }
}