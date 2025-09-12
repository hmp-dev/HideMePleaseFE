import ActivityKit
import WidgetKit
import SwiftUI

struct CheckInActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentUsers: Int // 현재 체크인한 유저 수 (업데이트 가능)
        var remainingUsers: Int // 매칭까지 남은 인원 수 (업데이트 가능)
    }
    
    var spaceName: String // 공간 이름은 변경 불가
    var maxCapacity: Int // 매장 최대 인원 (변경 불가)
}
