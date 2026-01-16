import Foundation
import ActivityKit
import Flutter
import WidgetKit

@available(iOS 16.1, *)
class CheckInLiveActivityManager: NSObject {
    static let shared = CheckInLiveActivityManager()

    private var currentActivity: Activity<CheckInActivityAttributes>?
    private var pushTokenTask: Task<Void, Never>?

    /// Live Activity 시작 및 Push Token 획득
    /// - completion: Push Token (hex string) 또는 nil
    func startLiveActivity(
        spaceName: String,
        spaceId: String,
        currentMembers: Int,
        requiredMembers: Int,
        checkedInAt: String,
        channel: FlutterMethodChannel,
        completion: @escaping (String?) -> Void
    ) {
        print("🔵 [LiveActivity] Starting Live Activity...")
        print("🔵 [LiveActivity] Space Name: \(spaceName), Space ID: \(spaceId)")
        print("🔵 [LiveActivity] Current Members: \(currentMembers), Required: \(requiredMembers)")

        // 권한 체크
        let authInfo = ActivityAuthorizationInfo()
        print("🔵 [LiveActivity] Activities Enabled: \(authInfo.areActivitiesEnabled)")
        if #available(iOS 16.2, *) {
            print("🔵 [LiveActivity] Frequent Push Enabled: \(authInfo.frequentPushesEnabled)")
        }

        if !authInfo.areActivitiesEnabled {
            print("⚠️ [LiveActivity] Live Activities are not enabled in settings!")
            channel.invokeMethod("liveActivityError", arguments: "Live Activities are not enabled")
            completion(nil)
            return
        }

        let attributes = CheckInActivityAttributes(
            spaceName: spaceName,
            spaceId: spaceId
        )

        let groupProgress = "\(currentMembers)/\(requiredMembers)"
        let initialState = CheckInActivityAttributes.ContentState(
            groupProgress: groupProgress,
            currentMembers: currentMembers,
            requiredMembers: requiredMembers,
            checkedInAt: checkedInAt,
            elapsedMinutes: 0,
            isCompleted: false,
            bonusPoints: nil
        )

        print("🔵 [LiveActivity] Attributes created, requesting activity with push...")

        do {
            // Push Type을 token으로 설정하여 Push 업데이트 활성화
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: .token
            )

            print("✅ [LiveActivity] Activity created successfully!")
            print("✅ [LiveActivity] Activity ID: \(currentActivity?.id ?? "nil")")

            channel.invokeMethod("liveActivityStarted", arguments: currentActivity?.id)

            // Push Token 획득 (비동기)
            observePushToken(completion: completion)

        } catch {
            print("❌ [LiveActivity] Failed to create activity: \(error)")
            print("❌ [LiveActivity] Error details: \(error.localizedDescription)")
            channel.invokeMethod("liveActivityError", arguments: error.localizedDescription)
            completion(nil)
        }
    }

    /// Push Token 변경 감지 및 획득
    private func observePushToken(completion: @escaping (String?) -> Void) {
        guard let activity = currentActivity else {
            completion(nil)
            return
        }

        // 기존 Task 취소
        pushTokenTask?.cancel()

        pushTokenTask = Task {
            for await tokenData in activity.pushTokenUpdates {
                guard !Task.isCancelled else { return }

                let token = tokenData.map { String(format: "%02x", $0) }.joined()
                print("✅ [LiveActivity] Push Token received: \(token)")

                // 첫 번째 토큰만 반환
                completion(token)
                return
            }
        }

        // 타임아웃: 5초 후에도 토큰이 없으면 nil 반환
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            if self?.pushTokenTask != nil {
                print("⚠️ [LiveActivity] Push Token timeout")
                self?.pushTokenTask?.cancel()
                self?.pushTokenTask = nil
                // completion은 이미 호출되었을 수 있으므로 체크 필요
            }
        }
    }

    /// Live Activity 상태 업데이트 (폴링 fallback용)
    func updateLiveActivity(
        groupProgress: String,
        currentMembers: Int,
        requiredMembers: Int,
        checkedInAt: String,
        elapsedMinutes: Int,
        isCompleted: Bool,
        bonusPoints: Int?
    ) {
        guard let activity = currentActivity else {
            print("⚠️ [LiveActivity] No current activity to update")
            return
        }

        print("🔵 [LiveActivity] Updating Live Activity...")
        print("🔵 [LiveActivity] Progress: \(groupProgress), Completed: \(isCompleted)")

        let updatedState = CheckInActivityAttributes.ContentState(
            groupProgress: groupProgress,
            currentMembers: currentMembers,
            requiredMembers: requiredMembers,
            checkedInAt: checkedInAt,
            elapsedMinutes: elapsedMinutes,
            isCompleted: isCompleted,
            bonusPoints: bonusPoints
        )

        Task {
            await activity.update(using: updatedState)
            print("✅ [LiveActivity] Activity updated successfully!")
        }
    }

    func endLiveActivity() {
        print("🔵 [LiveActivity] Ending Live Activity...")

        pushTokenTask?.cancel()
        pushTokenTask = nil

        // 현재 참조된 activity 종료
        if let activity = currentActivity {
            Task {
                await activity.end(dismissalPolicy: .immediate)
                print("✅ [LiveActivity] Current activity ended")
            }
        }

        currentActivity = nil

        // 모든 활성 Live Activity도 종료 (안전장치)
        endAllActivities()
    }

    /// 모든 활성 Live Activity 종료 (앱 시작 시 stale activity 정리용)
    func endAllActivities() {
        print("🔵 [LiveActivity] Ending all activities...")

        Task {
            for activity in Activity<CheckInActivityAttributes>.activities {
                print("🔵 [LiveActivity] Ending activity: \(activity.id)")
                await activity.end(dismissalPolicy: .immediate)
            }
            print("✅ [LiveActivity] All activities ended")
        }
    }
}