# 온보딩 디버깅 가이드

## 개요
온보딩 화면은 사용자가 진행 중 앱을 종료하더라도 마지막 진행 단계부터 재개할 수 있도록 구현되었습니다.

## 주요 기능

### 1. 진행 상태 저장
- 사용자가 온보딩 화면을 진행할 때마다 현재 단계가 자동 저장됩니다
- 앱을 종료하고 다시 시작해도 마지막 단계부터 계속 진행 가능합니다
- "하미플 세계로 입장" 버튼을 누르면 온보딩이 완료되고 저장된 단계가 초기화됩니다

### 2. 디버깅 모드
개발 중에는 디버깅 모드를 활성화하여 온보딩을 항상 볼 수 있습니다.

#### 디버깅 모드 활성화 방법:

```dart
// 앱 실행 초기에 다음 코드 추가 (예: main.dart 또는 초기화 함수)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';

Future<void> enableOnboardingDebugMode() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(StorageValues.onboardingDebugMode, true);
  print('✅ 온보딩 디버깅 모드 활성화됨');
}

// 호출 예시:
await enableOnboardingDebugMode();
```

#### 디버깅 모드 비활성화 방법:

```dart
Future<void> disableOnboardingDebugMode() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(StorageValues.onboardingDebugMode, false);
  print('❌ 온보딩 디버깅 모드 비활성화됨');
}
```

### 3. 온보딩 상태 초기화
테스트를 위해 온보딩을 완전히 초기화하려면:

```dart
Future<void> resetOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(StorageValues.onboardingCompleted);
  await prefs.remove(StorageValues.onboardingCurrentStep);
  print('🔄 온보딩 상태 초기화 완료');
}
```

## 저장되는 데이터

### SharedPreferences 키:
- `onboardingCompleted`: 온보딩 완료 여부 (bool)
- `onboardingCurrentStep`: 현재 진행 중인 단계 (int, 0-4)
- `onboardingDebugMode`: 디버깅 모드 활성화 여부 (bool)

## 온보딩 화면 단계
1. **0단계**: 하미플 세계 소개 
2. **1단계**: 지갑 생성 안내 (지갑이 있으면 자동 스킵)
3. **2단계**: 캐릭터 선택
4. **3단계**: 닉네임 입력
5. **4단계**: 완료 축하 화면

## 프로덕션 배포 시 주의사항

⚠️ **중요**: 프로덕션 배포 전에 반드시 디버깅 모드를 비활성화하세요!

```dart
// 프로덕션 배포 전 체크리스트:
// 1. 디버깅 모드 비활성화 코드 제거 또는 false 설정
// 2. 불필요한 로그 제거
// 3. 테스트 코드 제거
```

## 문제 해결

### 온보딩이 계속 나타나는 경우:
1. 디버깅 모드가 활성화되어 있는지 확인
2. `onboardingCompleted` 값 확인
3. 저장된 단계(`onboardingCurrentStep`) 확인

### 온보딩이 나타나지 않는 경우:
1. `onboardingCompleted`가 true로 설정되어 있는지 확인
2. 온보딩 상태 초기화 실행

## 테스트 시나리오

1. **중간 이탈 테스트**:
   - 각 단계에서 앱 종료
   - 앱 재시작 후 같은 단계에서 시작되는지 확인

2. **완료 테스트**:
   - 마지막 "하미플 세계로 입장" 버튼 클릭
   - 앱 재시작 후 온보딩이 나타나지 않는지 확인

3. **디버깅 모드 테스트**:
   - 디버깅 모드 활성화
   - 온보딩 완료 후에도 계속 나타나는지 확인