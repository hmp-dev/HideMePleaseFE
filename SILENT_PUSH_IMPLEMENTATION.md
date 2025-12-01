# Silent Push Implementation Guide for Check-in Heartbeat

## Overview
백그라운드에서 안정적으로 체크인 하트비트를 전송하기 위해 **Silent Push Notification** 방식을 사용합니다.

서버가 3분마다 Silent Push를 전송하여 앱을 깨우고, 앱이 하트비트를 전송합니다.

---

## 클라이언트 (Flutter) - ✅ 구현 완료

### 1. Silent Push 백그라운드 핸들러
**파일**: `lib/app/core/notifications/notification_service.dart`

```dart
// Silent Push 수신 시 자동으로 실행됨
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'CHECKIN_HEARTBEAT') {
    // 하트비트 전송
    await _handleHeartbeatSilentPush();
  }
}
```

### 2. WorkManager 백업
**파일**: `lib/app/core/services/check_in_location_service.dart`

- Silent Push가 메인 메커니즘
- WorkManager는 백업용 (3분 간격)

---

## 서버 (Backend) - 🔧 구현 필요

### 1. 체크인 API 수정

#### **Endpoint**: `POST /v1/spaces/{spaceId}/check-in`

**Request Body**:
```json
{
  "latitude": 37.5665,
  "longitude": 126.9780,
  "fcmToken": "fN3k2...your-fcm-token" // ← 추가
}
```

**처리 로직**:
```javascript
// 1. 체크인 정보 저장
const checkIn = await db.checkIns.create({
  userId: req.user.id,
  spaceId: req.params.spaceId,
  latitude: req.body.latitude,
  longitude: req.body.longitude,
  fcmToken: req.body.fcmToken, // FCM 토큰 저장
  checkedInAt: new Date(),
});

// 2. Silent Push 스케줄러에 등록
await scheduleHeartbeatPush(req.user.id, req.body.fcmToken);
```

---

### 2. Silent Push 스케줄러 구현

#### **기능**: 체크인 중인 사용자들에게 3분마다 Silent Push 전송

#### **구현 방법 (옵션)**

##### **Option A: Node.js Cron Job** (권장)
```javascript
const cron = require('node-cron');
const admin = require('firebase-admin');

// 3분마다 실행
cron.schedule('*/3 * * * *', async () => {
  console.log('💓 Sending heartbeat Silent Push...');

  // 체크인 중인 사용자 조회 (10분 이내 하트비트가 있는 사용자)
  const activeCheckIns = await db.checkIns.findAll({
    where: {
      status: 'ACTIVE',
      lastHeartbeatAt: {
        [Op.gte]: new Date(Date.now() - 10 * 60 * 1000) // 10분 이내
      }
    }
  });

  // 각 사용자에게 Silent Push 전송
  for (const checkIn of activeCheckIns) {
    await sendSilentPush(checkIn.fcmToken, checkIn.userId);
  }
});

async function sendSilentPush(fcmToken, userId) {
  const message = {
    token: fcmToken,
    data: {
      type: 'CHECKIN_HEARTBEAT', // ← 클라이언트에서 감지하는 타입
    },
    // Silent Push 설정
    apns: {
      headers: {
        'apns-priority': '5',
        'apns-push-type': 'background',
      },
      payload: {
        aps: {
          'content-available': 1, // iOS Silent Push
        },
      },
    },
    android: {
      priority: 'high', // Android 우선순위
    },
  };

  try {
    await admin.messaging().send(message);
    console.log(`✅ Silent Push sent to user ${userId}`);
  } catch (error) {
    console.error(`❌ Failed to send Silent Push to user ${userId}:`, error);
  }
}
```

##### **Option B: AWS Lambda + CloudWatch Events**
```javascript
// Lambda 함수: 3분마다 CloudWatch Events로 트리거
exports.handler = async (event) => {
  const activeCheckIns = await getActiveCheckIns();

  for (const checkIn of activeCheckIns) {
    await sendSilentPush(checkIn.fcmToken);
  }
};
```

##### **Option C: Bull Queue (권장 - 확장 가능)**
```javascript
const Queue = require('bull');
const heartbeatQueue = new Queue('heartbeat-push', 'redis://localhost:6379');

// 체크인 시 큐에 추가
async function scheduleHeartbeatPush(userId, fcmToken) {
  await heartbeatQueue.add(
    { userId, fcmToken },
    {
      repeat: {
        every: 3 * 60 * 1000, // 3분마다
      },
      jobId: `heartbeat-${userId}`, // 중복 방지
    }
  );
}

// Worker: Silent Push 전송
heartbeatQueue.process(async (job) => {
  await sendSilentPush(job.data.fcmToken, job.data.userId);
});
```

---

### 3. 체크아웃 API 수정

#### **Endpoint**: `POST /v1/spaces/{spaceId}/check-out`

**처리 로직**:
```javascript
// 1. 체크아웃 처리
await db.checkIns.update(
  { status: 'CHECKED_OUT', checkedOutAt: new Date() },
  { where: { userId: req.user.id, spaceId: req.params.spaceId } }
);

// 2. Silent Push 중단
await stopHeartbeatPush(req.user.id);
```

**Bull Queue 사용 시**:
```javascript
async function stopHeartbeatPush(userId) {
  // 반복 작업 제거
  await heartbeatQueue.removeRepeatable('heartbeat-push', {
    jobId: `heartbeat-${userId}`,
  });
}
```

---

### 4. 하트비트 API (기존 유지)

#### **Endpoint**: `POST /v1/spaces/{spaceId}/heartbeat`

**Request Body**:
```json
{
  "latitude": 37.5665,
  "longitude": 126.9780
}
```

**처리 로직**:
```javascript
// 1. 하트비트 시간 업데이트
await db.checkIns.update(
  { lastHeartbeatAt: new Date() },
  { where: { userId: req.user.id, spaceId: req.params.spaceId } }
);

// 2. 거리 체크 (선택사항 - 클라이언트도 체크함)
const checkIn = await db.checkIns.findOne({
  where: { userId: req.user.id, spaceId: req.params.spaceId }
});

const distance = calculateDistance(
  checkIn.latitude,
  checkIn.longitude,
  req.body.latitude,
  req.body.longitude
);

if (distance > 50) {
  // 자동 체크아웃
  await autoCheckOut(req.user.id, req.params.spaceId);
  await stopHeartbeatPush(req.user.id);
}
```

---

## 동작 흐름

```
사용자 체크인
    ↓
서버: FCM 토큰 저장 + Silent Push 스케줄 등록
    ↓
서버: 3분마다 Silent Push 전송
    ↓
앱: Push 받으면 깨어남 (iOS/Android)
    ↓
앱: 하트비트 전송 + 거리 체크
    ↓
서버: 하트비트 시간 업데이트
    ↓
사용자 체크아웃 또는 거리 초과
    ↓
서버: Silent Push 중단
```

---

## 테스트 방법

### 1. 클라이언트 테스트 (수동 Push)
Firebase Console에서 테스트 메시지 전송:

```json
{
  "data": {
    "type": "CHECKIN_HEARTBEAT"
  },
  "token": "사용자-FCM-토큰"
}
```

### 2. 서버 로그 확인
```
💓 Sending heartbeat Silent Push...
✅ Silent Push sent to user 123
📩 Background message received (클라이언트)
💓 Silent Push for heartbeat received (클라이언트)
✅ Heartbeat sent successfully via Silent Push (클라이언트)
```

---

## 주의사항

### iOS
- **Silent Push는 "content-available": 1 필수**
- Low Power Mode에서는 지연될 수 있음
- Background App Refresh 꺼져있으면 작동 안 함

### Android
- **Priority "high" 필수**
- Doze 모드에서도 거의 100% 작동
- 제조사별 배터리 최적화 설정 필요

### FCM Quota
- FCM 메시지 제한 확인
- 체크인 중인 사용자가 많으면 Batch 전송 고려

---

## 예상 효과

| 항목 | 기존 (WorkManager) | 개선 (Silent Push) |
|------|-------------------|-------------------|
| **안정성** | 60-70% | 95-100% |
| **주기** | 5-15분 지연 | 3분 정확 |
| **iOS** | 15분+ 지연 | 거의 즉시 |
| **Android** | 7-10분 지연 | 거의 즉시 |
| **Doze 모드** | 영향 받음 | 거의 무시 |

---

## 구현 우선순위

1. ✅ **클라이언트 구현** (완료)
2. 🔧 **서버: 체크인/체크아웃 API 수정** (FCM 토큰 저장/삭제)
3. 🔧 **서버: Silent Push 스케줄러 구현** (3분 주기)
4. 🧪 **테스트** (Firebase Console로 수동 테스트)
5. 📊 **모니터링** (하트비트 성공률 추적)

---

## 문의사항

구현 중 문제가 있으면 클라이언트 팀에 문의하세요.
클라이언트 구현은 완료되었습니다!
