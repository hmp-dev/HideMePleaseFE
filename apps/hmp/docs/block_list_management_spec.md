# 차단 목록 관리 기능 구현 명세서

## 개요
설정 화면에서 차단된 사용자 목록을 확인하고 차단 해제할 수 있는 기능

## 화면 흐름
```
설정 화면 (settings_view.dart)
    └── "차단 목록" 메뉴 클릭
            └── 차단 목록 화면 (block_list_screen.dart)
                    └── 차단 해제 버튼 클릭
                            └── 차단 해제 확인 다이얼로그
                                    └── 차단 해제 완료
```

---

## 1. 수정 파일

### 1.1 번역 파일
| 파일 | 추가 내용 |
|------|----------|
| `assets/translations/ko.json` | 차단 목록 관련 한국어 번역 |
| `assets/translations/en.json` | 차단 목록 관련 영어 번역 |

**번역 키:**
```json
// ko.json
"block_list": "차단 목록",
"block_list_empty": "차단된 사용자가 없어.",
"unblock_user": "차단 해제",
"unblock_user_title": "차단 해제",
"unblock_user_message": "이 사용자의 차단을 해제할까?\n해제하면 다시 게시글이 보여.",
"unblock_user_confirm": "해제하기",
"unblock_user_cancel": "취소",
"unblock_user_success": "차단이 해제됐어."

// en.json
"block_list": "Blocked Users",
"block_list_empty": "No blocked users.",
"unblock_user": "Unblock",
"unblock_user_title": "Unblock User",
"unblock_user_message": "Are you sure you want to unblock this user?\nTheir posts will be visible again.",
"unblock_user_confirm": "Unblock",
"unblock_user_cancel": "Cancel",
"unblock_user_success": "User has been unblocked."
```

### 1.2 Storage 상수
| 파일 | 변경 내용 |
|------|----------|
| `lib/app/core/constants/storage.dart` | 이미 `blockedUserIds` 키 존재 (변경 없음) |

### 1.3 Cubit/State
| 파일 | 변경 내용 |
|------|----------|
| `lib/features/space/presentation/cubit/siren_cubit.dart` | `unblockUser()` 메서드 추가 |
| `lib/features/space/presentation/cubit/siren_state.dart` | 변경 없음 (blockedUserIds 이미 존재) |

### 1.4 신규 화면
| 파일 | 설명 |
|------|------|
| `lib/features/settings/presentation/screens/block_list_screen.dart` | 차단 목록 화면 (신규) |

### 1.5 설정 화면
| 파일 | 변경 내용 |
|------|----------|
| `lib/features/settings/presentation/views/settings_view.dart` | 차단 목록 메뉴 추가 |

---

## 2. 구현 상세

### 2.1 SirenCubit - unblockUser 메서드 추가

**파일:** `lib/features/space/presentation/cubit/siren_cubit.dart`

```dart
/// 사용자 차단 해제
Future<void> unblockUser(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final blocked = prefs.getStringList(StorageValues.blockedUserIds) ?? [];

  blocked.remove(userId);
  await prefs.setStringList(StorageValues.blockedUserIds, blocked);

  emit(state.copyWith(blockedUserIds: blocked.toSet()));
}

/// 차단된 사용자 ID 목록 반환
Set<String> getBlockedUserIds() {
  return state.blockedUserIds;
}
```

### 2.2 차단 목록 화면

**파일:** `lib/features/settings/presentation/screens/block_list_screen.dart`

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/space/presentation/cubit/siren_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/siren_state.dart';
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  static Future<dynamic> push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlockListScreen()),
    );
  }

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  final SirenCubit _sirenCubit = getIt<SirenCubit>();
  Map<String, UserInfo> _userInfoMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    await _sirenCubit.loadBlockedUserIds();
    final blockedIds = _sirenCubit.state.blockedUserIds;

    // 각 차단된 유저의 프로필 정보 로드
    final dataSource = getIt<ProfileRemoteDataSource>();
    for (final userId in blockedIds) {
      try {
        final profile = await dataSource.getUserProfile(userId: userId);
        _userInfoMap[userId] = UserInfo(
          userId: userId,
          nickName: profile.toEntity().nickName,
          profileImageUrl: profile.toEntity().finalProfileImageUrl,
        );
      } catch (e) {
        _userInfoMap[userId] = UserInfo(
          userId: userId,
          nickName: 'Unknown',
          profileImageUrl: null,
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.block_list.tr(),
      isCenterTitle: true,
      onBack: () => Navigator.pop(context),
      body: BlocBuilder<SirenCubit, SirenState>(
        bloc: _sirenCubit,
        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.blockedUserIds.isEmpty) {
            return _buildEmptyState();
          }

          return _buildBlockedUserList(state.blockedUserIds);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        LocaleKeys.block_list_empty.tr(),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF132E41),
        ),
      ),
    );
  }

  Widget _buildBlockedUserList(Set<String> blockedUserIds) {
    final userIds = blockedUserIds.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: userIds.length,
      itemBuilder: (context, index) {
        final userId = userIds[index];
        final userInfo = _userInfoMap[userId];

        return _buildBlockedUserTile(userId, userInfo);
      },
    );
  }

  Widget _buildBlockedUserTile(String userId, UserInfo? userInfo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF132E41), width: 1),
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFFEAF8FF),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: userInfo?.profileImageUrl != null
                  ? Image.network(
                      userInfo!.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(width: 12),

          // 닉네임
          Expanded(
            child: Text(
              userInfo?.nickName ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF132E41),
              ),
            ),
          ),

          // 차단 해제 버튼
          GestureDetector(
            onTap: () => _showUnblockDialog(userId, userInfo?.nickName ?? 'Unknown'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00A3FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                LocaleKeys.unblock_user.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Image.asset(
      'assets/images/profile_img.png',
      fit: BoxFit.cover,
    );
  }

  void _showUnblockDialog(String userId, String nickName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFEAF8FF),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF132E41), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.unblock_user_title.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132E41),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.unblock_user_message.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF132E41),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0x4D000000),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.unblock_user_cancel.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _sirenCubit.unblockUser(userId);
                          _userInfoMap.remove(userId);
                          setState(() {});
                          _showUnblockSuccessSnackbar();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A3FF),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.unblock_user_confirm.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUnblockSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.unblock_user_success.tr()),
        backgroundColor: const Color(0xFF00A3FF),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class UserInfo {
  final String userId;
  final String nickName;
  final String? profileImageUrl;

  UserInfo({
    required this.userId,
    required this.nickName,
    this.profileImageUrl,
  });
}
```

### 2.3 설정 화면에 메뉴 추가

**파일:** `lib/features/settings/presentation/views/settings_view.dart`

**위치:** `userSettings` 섹션 내, `buildLocationConcent()` 아래에 추가

```dart
// import 추가
import 'package:mobile/features/settings/presentation/screens/block_list_screen.dart';

// buildLocationConcent() 아래에 추가
FeatureTile(
  title: LocaleKeys.block_list.tr(),
  onTap: () {
    BlockListScreen.push(context);
  },
),
```

---

## 3. UI/UX 상세

### 3.1 차단 목록 화면 레이아웃
```
┌─────────────────────────────────┐
│  ←  차단 목록                    │  <- 앱바
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────────┐│
│  │ [이미지] 닉네임    [차단해제]││  <- 차단된 유저 아이템
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ [이미지] 닉네임    [차단해제]││
│  └─────────────────────────────┘│
│                                 │
│         ...                     │
│                                 │
└─────────────────────────────────┘
```

### 3.2 빈 상태
```
┌─────────────────────────────────┐
│  ←  차단 목록                    │
├─────────────────────────────────┤
│                                 │
│                                 │
│       차단된 사용자가 없어.       │  <- 중앙 정렬
│                                 │
│                                 │
└─────────────────────────────────┘
```

### 3.3 색상 스펙
| 요소 | 색상 코드 |
|------|----------|
| 차단 해제 버튼 배경 | `#00A3FF` (파란색) |
| 아이템 배경 | `#FFFFFF` (흰색) |
| 아이템 테두리 | `#132E41` |
| 텍스트 | `#132E41` |

---

## 4. 구현 순서

1. **번역 키 추가** (`ko.json`, `en.json`)
2. **locale_keys.g.dart 재생성** (`flutter pub run easy_localization:generate`)
3. **SirenCubit에 unblockUser 메서드 추가**
4. **BlockListScreen 생성**
5. **settings_view.dart에 메뉴 추가**
6. **테스트**

---

## 5. 테스트 시나리오

| # | 시나리오 | 예상 결과 |
|---|---------|----------|
| 1 | 차단된 유저가 없는 상태에서 차단 목록 진입 | "차단된 사용자가 없어." 메시지 표시 |
| 2 | 차단된 유저가 있는 상태에서 차단 목록 진입 | 차단된 유저 목록 표시 |
| 3 | 차단 해제 버튼 클릭 | 확인 다이얼로그 표시 |
| 4 | 차단 해제 확인 | 목록에서 제거 + 스낵바 표시 |
| 5 | 차단 해제 후 사이렌 목록 확인 | 해제된 유저의 사이렌 다시 표시 |

---

## 6. 연관 파일 요약

```
apps/hmp/
├── assets/translations/
│   ├── ko.json                    # 번역 추가
│   └── en.json                    # 번역 추가
├── lib/
│   ├── app/core/constants/
│   │   └── storage.dart           # blockedUserIds 키 (기존)
│   ├── features/
│   │   ├── settings/presentation/
│   │   │   ├── screens/
│   │   │   │   └── block_list_screen.dart  # 신규 생성
│   │   │   └── views/
│   │   │       └── settings_view.dart      # 메뉴 추가
│   │   └── space/presentation/cubit/
│   │       └── siren_cubit.dart            # unblockUser 메서드 추가
│   └── generated/
│       └── locale_keys.g.dart              # 재생성
```
