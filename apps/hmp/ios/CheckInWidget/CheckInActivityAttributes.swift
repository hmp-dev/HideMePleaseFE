import ActivityKit
import WidgetKit
import SwiftUI

struct CheckInActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var groupProgress: String       // "3/5" 형태
        var currentMembers: Int         // 현재 체크인 인원
        var requiredMembers: Int        // 매칭에 필요한 인원
        var checkedInAt: String         // ISO 8601 체크인 시간
        var elapsedMinutes: Int         // 경과 시간 (분)
        var isCompleted: Bool           // 매칭 완료 여부
        var bonusPoints: Int?           // 보너스 포인트 (optional)
    }

    var spaceName: String   // 공간 이름 (변경 불가)
    var spaceId: String     // 공간 ID (변경 불가)
}
