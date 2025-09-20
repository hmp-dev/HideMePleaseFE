import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/services/share_image_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareDialog extends StatefulWidget {
  final SpaceDetailEntity spaceDetailEntity;
  final SpaceEntity? spaceEntity;

  const ShareDialog({
    super.key,
    required this.spaceDetailEntity,
    this.spaceEntity,
  });

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  bool _isGenerating = false;
  Uint8List? _generatedImage;
  String? _selectedImagePath;
  int _selectedTab = 0; // 0: 매장 사진, 1: 내 사진
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _generateShareImage();
  }

  Future<void> _selectImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _selectedTab = 1;
        });
        _generateShareImage();
      }
    } catch (e) {
      '❌ Error selecting image: $e'.log();
      _showErrorMessage('이미지 선택 중 오류가 발생했습니다');
    }
  }

  Future<void> _generateShareImage() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final profileCubit = getIt<ProfileCubit>();
      final userProfile = profileCubit.state.userProfileEntity;

      if (userProfile == null) {
        '❌ User profile not available'.log();
        return;
      }

      // Use selected image or store image
      final backgroundImageUrl = _selectedTab == 0
          ? widget.spaceDetailEntity.image
          : _selectedImagePath;

      // Generate the share image
      final imageBytes = await ShareImageService.generateShareImage(
        storeImageUrl: backgroundImageUrl ?? '',
        storeName: widget.spaceDetailEntity.name,
        userProfileImageUrl: userProfile.finalProfileImageUrl ?? userProfile.pfpImageUrl ?? '',
        profilePartsString: userProfile.profilePartsString,  // 레이어드 아바타 데이터 추가
        userName: userProfile.nickName ?? 'Anonymous',
        checkInTime: DateTime.now(),
        hiddenTimeMinutes: 30, // Default hidden time
        isLocalImage: _selectedTab == 1,
      );

      if (mounted) {
        setState(() {
          _generatedImage = imageBytes;
          _isGenerating = false;
        });
      }
    } catch (e) {
      '❌ Error generating share image: $e'.log();
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _shareToX() async {
    if (_generatedImage == null) return;

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/hmp_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);

      final xFile = XFile(file.path);
      // X(트위터) 앱 직접 열기
      final text = Uri.encodeComponent('${widget.spaceDetailEntity.name}에서 Hidden Time! 🫵 #HideMePlease');

      // 다양한 X/Twitter URL scheme 시도
      final schemes = [
        'twitter://post?text=$text',
        'x://post?text=$text',
        'https://twitter.com/intent/tweet?text=$text'
      ];

      bool appOpened = false;
      for (final scheme in schemes) {
        final url = Uri.parse(scheme);
        if (await canLaunchUrl(url)) {
          appOpened = await launchUrl(url, mode: LaunchMode.externalApplication);
          if (appOpened) break;
        }
      }

      // 시스템 공유 시트 호출
      await Share.shareXFiles(
        [xFile],
        text: '${widget.spaceDetailEntity.name}에서 Hidden Time! 🫵 #HideMePlease',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      '❌ Error sharing to X: $e'.log();
      _showErrorMessage('X 공유 중 오류가 발생했습니다');
    }
  }

  Future<void> _shareToThreads() async {
    if (_generatedImage == null) return;

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/hmp_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);

      final xFile = XFile(file.path);
      // Threads 앱 직접 열기
      final text = Uri.encodeComponent('${widget.spaceDetailEntity.name}에서 Hidden Time! 🫵 #HideMePlease');

      // Threads URL schemes
      final schemes = [
        'barcelona://create?text=$text',
        'threads://create?text=$text',
        'fb://facewebmodal/f?href=https://threads.net/intent/post?text=$text'
      ];

      bool appOpened = false;
      for (final scheme in schemes) {
        final url = Uri.parse(scheme);
        if (await canLaunchUrl(url)) {
          appOpened = await launchUrl(url, mode: LaunchMode.externalApplication);
          if (appOpened) break;
        }
      }

      // 시스템 공유 시트 호출
      await Share.shareXFiles(
        [xFile],
        text: '${widget.spaceDetailEntity.name}에서 Hidden Time! 🫵',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      '❌ Error sharing to Threads: $e'.log();
      _showErrorMessage('Threads 공유 중 오류가 발생했습니다');
    }
  }

  Future<void> _shareToInstagram() async {
    if (_generatedImage == null) return;

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/hmp_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);

      final xFile = XFile(file.path);

      // Instagram 앱 직접 열기
      final schemes = [
        'instagram://app',  // Instagram 메인 앱 열기
        'instagram://camera', // Instagram 카메라 열기
        'instagram-stories://share', // Instagram Stories
      ];

      bool appOpened = false;
      for (final scheme in schemes) {
        final url = Uri.parse(scheme);
        if (await canLaunchUrl(url)) {
          appOpened = await launchUrl(url, mode: LaunchMode.externalApplication);
          if (appOpened) break;
        }
      }

      // 앱이 열렸든 안 열렸든 Share를 통해 이미지 공유
      // Instagram은 Share sheet를 통해 이미지를 받음
      await Share.shareXFiles(
        [xFile],
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      '❌ Error sharing to Instagram: $e'.log();
      _showErrorMessage('Instagram 공유 중 오류가 발생했습니다');
    }
  }

  Future<void> _downloadImage() async {
    if (_generatedImage == null) {
      _showErrorMessage('저장할 이미지가 없습니다');
      return;
    }

    '💾 Starting image download'.log();

    try {
      // iOS는 권한 체크 없이 바로 저장 시도 (시스템이 자동으로 권한 요청)
      if (Platform.isIOS) {
        '🍎 iOS detected, saving directly'.log();
        try {
          await Gal.putImageBytes(
            _generatedImage!,
            album: 'HideMePlease',
          );
          '💾 Image saved successfully'.log();
          _showSuccessMessage('이미지가 갤러리에 저장되었습니다');
        } catch (e) {
          '❌ Save error: $e'.log();
          _showErrorMessage('이미지 저장에 실패했습니다');
        }
      } else if (Platform.isAndroid) {
        '🤖 Android detected, checking permissions'.log();

        // Android 권한 처리
        bool hasPermission = false;
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+ uses photos permission
          final status = await Permission.photos.request();
          hasPermission = status.isGranted || status.isLimited;
          '📱 Android 13+ photos permission: $status'.log();
        } else if (androidInfo.version.sdkInt >= 29) {
          // Android 10-12 doesn't need permission for MediaStore
          hasPermission = true;
          '📱 Android 10-12 no permission needed'.log();
        } else {
          // Older Android versions use storage permission
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
          '📱 Android <10 storage permission: $status'.log();
        }

        if (hasPermission) {
          try {
            await Gal.putImageBytes(
              _generatedImage!,
              album: 'HideMePlease',
            );
            '💾 Image saved successfully'.log();
            _showSuccessMessage('이미지가 갤러리에 저장되었습니다');
          } catch (e) {
            '❌ Save error: $e'.log();
            _showErrorMessage('이미지 저장에 실패했습니다');
          }
        } else {
          _showErrorMessage('저장 권한이 필요합니다');
        }
      }
    } catch (e) {
      '❌ Error downloading image: $e'.log();
      _showErrorMessage('이미지 저장 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main dialog content
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Tab selector
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                          _selectedImagePath = null;
                        });
                        _generateShareImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? Colors.black87
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '매장 사진',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectImageFromGallery,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? Colors.black87
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '내 사진',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Preview Image - 1:1 \ube44\uc728\ub85c \ubcc0\uacbd
            Center(
              child: Container(
                height: 300,
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isGenerating
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF19BAFF),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '이미지 생성 중...',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _generatedImage != null
                        ? Image.memory(
                            _generatedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : const Center(
                            child: Text(
                              '이미지를 생성할 수 없습니다',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ),
              ),
              ),
            ),

            // Share message
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                '숨어있는 소식을 친구들에게 알려봐!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Share Options - Horizontal layout with spacing
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShareOption(
                    iconPath: 'assets/images/share_x.png',
                    label: 'X',
                    onTap: _shareToX,
                    enabled: !_isGenerating && _generatedImage != null,
                  ),
                  const SizedBox(width: 8),  // 버튼 사이 여백
                  _buildShareOption(
                    iconPath: 'assets/images/share_threads.png',
                    label: 'Threads',
                    onTap: _shareToThreads,
                    enabled: !_isGenerating && _generatedImage != null,
                  ),
                  const SizedBox(width: 8),  // 버튼 사이 여백
                  _buildShareOption(
                    iconPath: 'assets/images/share_instagram.png',
                    label: 'Instagram',
                    onTap: _shareToInstagram,
                    enabled: !_isGenerating && _generatedImage != null,
                  ),
                  const SizedBox(width: 8),  // 버튼 사이 여백
                  _buildShareOption(
                    iconPath: 'assets/images/share_download.png',
                    label: 'Download',
                    onTap: _downloadImage,
                    enabled: !_isGenerating && _generatedImage != null,
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
          // Close button - 다이얼로그 바깥에 위치
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Column(
          children: [
            Container(
              width: 72,  // 크기 약간 줄임
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF132E41),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: iconPath.contains('share_x') ? 18 : 20,  // X icon slightly smaller
                  height: iconPath.contains('share_x') ? 18 : 20,
                  // Remove color tinting to show original icon colors
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? Colors.black87 : Colors.black38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}