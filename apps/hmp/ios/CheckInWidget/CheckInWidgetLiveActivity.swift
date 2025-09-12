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
                    Text("\(context.state.currentUsers)/\(context.attributes.maxCapacity)")
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
                        HStack(spacing: 4) {
                            Text("매칭까지")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("\(context.state.remainingUsers)명")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))
                            
                            Text("남음")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
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
                Text("\(context.state.currentUsers)/\(context.attributes.maxCapacity)")
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
    
    var body: some View {
        ZStack {
            // 검정 배경
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
                    
                    // 오른쪽: 5개 점 표시
                    HStack(spacing: 6) {
                        ForEach(0..<context.attributes.maxCapacity, id: \.self) { index in
                            Circle()
                                .fill(index < context.state.currentUsers ? 
                                      Color(red: 0.17, green: 0.70, blue: 1.0) : // 파란색
                                      Color.white.opacity(0.3)) // 회색
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20) // 상단 여백 20pt
                
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
                        }
                        
                        // 매칭 상태
                        HStack(spacing: 4) {
                            Text("매칭 성공까지")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("\(context.state.remainingUsers)명")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0)) // 파란색
                            
                            Text("남음")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.17, green: 0.70, blue: 1.0))
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
                        
                        // 아이콘과 큰 숫자
                        HStack(spacing: 8) {
                            Image("ico_savlive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                            
                            Text("3")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.18)) // 주황색
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 20) // 하단 여백 20pt
            }
        }
        .frame(height: 140) // Live Activity 높이 설정
    }
}

// Preview는 iOS 17+ 에서만 가능
// 실제 앱에서 테스트 필요
