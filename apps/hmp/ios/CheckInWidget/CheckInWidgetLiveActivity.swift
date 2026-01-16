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
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View - Dynamic Island를 길게 눌렀을 때
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image("ico_logolive")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)

                        Text("하이드미플리즈")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.groupProgress)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.trailing, 8)
                }

                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        // 공간 이름
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))

                            Text(context.attributes.spaceName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        // 매칭 상태
                        if context.state.isCompleted {
                            HStack(spacing: 4) {
                                Text("매칭 완료!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))

                                if let bonusPoints = context.state.bonusPoints {
                                    Text("+\(bonusPoints) SAV")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.18))
                                }
                            }
                        } else {
                            let remainingUsers = context.state.requiredMembers - context.state.currentMembers
                            HStack(spacing: 4) {
                                Text("매칭까지")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)

                                Text("\(remainingUsers)명")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))

                                Text("남음")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }

            } compactLeading: {
                // Compact Leading - 왼쪽 작은 영역
                HStack(spacing: 4) {
                    Image("ico_logolive")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)

                    Text("하이드미플리즈")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
            } compactTrailing: {
                // Compact Trailing - 오른쪽 작은 영역
                Text(context.state.groupProgress)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } minimal: {
                // Minimal - 가장 작은 상태
                Image("ico_logolive")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
        }
    }
}

struct CheckInLiveActivityView: View {
    let context: ActivityViewContext<CheckInActivityAttributes>

    private var remainingUsers: Int {
        context.state.requiredMembers - context.state.currentMembers
    }

    var body: some View {
        ZStack {
            // 배경
            Color(red: 0.9176, green: 0.9725, blue: 1.0, opacity: 1.0)

            VStack(spacing: 0) {
                // 상단: 로고 + 하이드미플리즈 + 점 표시
                HStack {
                    // 왼쪽: 로고 + 텍스트
                    HStack(spacing: 8) {
                        Image("ico_logolive")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)

                        Text("하이드미플리즈")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    // 오른쪽: 점 표시 (requiredMembers 기준, map_info_card.dart와 동일)
                    HStack(spacing: 4) {
                        ForEach(0..<context.state.requiredMembers, id: \.self) { index in
                            Circle()
                                .fill(index < context.state.currentMembers ?
                                      Color(red: 0.0, green: 0.639, blue: 1.0) : // 파란색 (0xFF00A3FF)
                                      Color.clear) // 투명
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // 중앙 및 하단 콘텐츠
                HStack(alignment: .bottom, spacing: 0) {
                    // 왼쪽 영역
                    VStack(alignment: .leading, spacing: 8) {
                        // 공간 이름
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 16))

                            Text(context.attributes.spaceName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)

                            // 경과 시간
                            if context.state.elapsedMinutes > 0 {
                                Text("• \(context.state.elapsedMinutes)분")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }

                        // 매칭 상태
                        if context.state.isCompleted {
                            HStack(spacing: 4) {
                                Text("매칭 완료!")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))
                            }
                        } else {
                            HStack(spacing: 4) {
                                Text("매칭 성공까지")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)

                                Text("\(remainingUsers)명")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))

                                Text("남음")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))
                            }
                        }
                    }
                    .padding(.leading, 20)

                    Spacer()

                    // 오른쪽 영역: SAV 리워드 + 아이콘과 숫자
                    VStack(alignment: .trailing, spacing: 4) {
                        // SAV 리워드
                        Text("SAV 리워드")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.7))

                        // 아이콘과 보너스 포인트
                        HStack(spacing: 8) {
                            Image("ico_savlive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)

                            Text("\(context.state.bonusPoints ?? 3)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.18))
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .frame(height: 140)
    }
}

// Preview는 iOS 17+ 에서만 가능
// 실제 앱에서 테스트 필요
