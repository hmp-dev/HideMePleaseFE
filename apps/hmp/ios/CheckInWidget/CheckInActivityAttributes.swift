import ActivityKit
import WidgetKit
import SwiftUI

struct CheckInActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingTime: Int
        var isConfirmed: Bool
    }
    
    var spaceName: String
    var benefit: String
    var checkInTime: Date
}
