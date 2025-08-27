//
//  CheckInWidgetLiveActivity.swift
//  CheckInWidget
//
//  Created by takout on 8/26/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CheckInWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CheckInActivityAttributes.self) { context in
            // Lock screen/banner UI
            CheckInLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                        
                        Text(context.attributes.spaceName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timeString(from: context.state.remainingTime))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.18))
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("매칭 성공까지 1명 남음")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(context.attributes.benefit)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            } compactLeading: {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            } compactTrailing: {
                Text(timeString(from: context.state.remainingTime))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.18))
            } minimal: {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.white)
            }
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간"
        } else if minutes > 0 {
            return "\(minutes)분"
        } else {
            return "\(seconds)초"
        }
    }
}

struct CheckInLiveActivityView: View {
    let context: ActivityViewContext<CheckInActivityAttributes>
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side content
            VStack(alignment: .leading, spacing: 8) {
                // HideMePlease logo and space name
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    
                    Text("영동호프")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Main text
                HStack(spacing: 4) {
                    Text("매칭 성공까지")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("1명 남음")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))
                }
                
                // SAV Reward text
                Text("SAV 리워드")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 20)
            
            Spacer()
            
            // Right side timer
            VStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.18))
                    .font(.system(size: 24))
                
                Text(timeString(from: context.state.remainingTime))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.18))
            }
            .padding(.trailing, 20)
        }
        .padding(.vertical, 16)
        .background(Color.black)
        .activityBackgroundTint(Color.black)
    }
    
    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// Preview is only available in iOS 17+
// To test Live Activities, use the actual app instead of previews
