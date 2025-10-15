import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:mobile/generated/locale_keys.g.dart';
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
      _showErrorMessage(LocaleKeys.share_select_error.tr());
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
      // 먼저 갤러리에 이미지 저장
      final saved = await _saveImageToGallery(showToast: false);
      if (saved) {
        _showSuccessMessage(LocaleKeys.share_image_saved_select.tr());
      }

      // X(Twitter) 앱 직접 열기 시도
      final message = Uri.encodeComponent('${widget.spaceDetailEntity.name}${LocaleKeys.share_message_hidden_time.tr()}');
      final twitterUrl = Uri.parse('twitter://post?message=$message');

      try {
        final canLaunch = await canLaunchUrl(twitterUrl);
        if (canLaunch) {
          await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
          '✅ Opened X app directly'.log();
          return;
        }
      } catch (e) {
        '⚠️ Failed to open X app, falling back to share sheet: $e'.log();
      }

      // Fallback: 시스템 공유 시트
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/hmp_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);

      final xFile = XFile(file.path);

      await Share.shareXFiles(
        [xFile],
        text: '${widget.spaceDetailEntity.name}${LocaleKeys.share_message_hidden_time.tr()}',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      '❌ Error sharing to X: $e'.log();
      _showErrorMessage(LocaleKeys.share_x_error.tr());
    }
  }

  Future<void> _shareToThreads() async {
    if (_generatedImage == null) return;

    try {
      // 먼저 갤러리에 이미지 저장
      final saved = await _saveImageToGallery(showToast: false);
      if (saved) {
        _showSuccessMessage(LocaleKeys.share_image_saved_select.tr());
      }

      // Threads 앱 직접 열기 시도
      final message = Uri.encodeComponent('${widget.spaceDetailEntity.name}${LocaleKeys.share_message_hidden_time.tr()}');
      final threadsUrl = Uri.parse('threads://compose?text=$message');

      try {
        final canLaunch = await canLaunchUrl(threadsUrl);
        if (canLaunch) {
          await launchUrl(threadsUrl, mode: LaunchMode.externalApplication);
          '✅ Opened Threads app directly'.log();
          return;
        }
      } catch (e) {
        '⚠️ Failed to open Threads app, falling back to share sheet: $e'.log();
      }

      // Fallback: 시스템 공유 시트
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/hmp_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);

      final xFile = XFile(file.path);

      await Share.shareXFiles(
        [xFile],
        text: '${widget.spaceDetailEntity.name}${LocaleKeys.share_message_hidden_time_short.tr()}',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      '❌ Error sharing to Threads: $e'.log();
      _showErrorMessage(LocaleKeys.share_threads_error.tr());
    }
  }

  Future<void> _shareToInstagram() async {
    if (_generatedImage == null) return;

    try {
      // 먼저 갤러리에 이미지 저장
      final saved = await _saveImageToGallery(showToast: false);
      if (saved) {
        _showSuccessMessage(LocaleKeys.share_image_saved_select.tr());
      }

      // Instagram 앱 직접 열기 시도 (카메라로)
      final instagramUrl = Uri.parse('instagram://camera');

      try {
        final canLaunch = await canLaunchUrl(instagramUrl);
        if (canLaunch) {
          await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
          '✅ Opened Instagram app directly'.log();
          return;
        }
      } catch (e) {
        '⚠️ Failed to open Instagram app, falling back to share sheet: $e'.log();
      }

      // Fallback: 시스템 공유 시트
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/hmp_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);

      final xFile = XFile(file.path);

      await Share.shareXFiles(
        [xFile],
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      '❌ Error sharing to Instagram: $e'.log();
      _showErrorMessage(LocaleKeys.share_instagram_error.tr());
    }
  }

  /// Save image to gallery (common method for all share actions)
  Future<bool> _saveImageToGallery({bool showToast = true}) async {
    if (_generatedImage == null) {
      if (showToast) _showErrorMessage(LocaleKeys.share_no_image_to_save.tr());
      return false;
    }

    '💾 Starting image save to gallery'.log();

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
          if (showToast) _showSuccessMessage(LocaleKeys.share_image_saved_gallery.tr());
          return true;
        } catch (e) {
          '❌ Save error: $e'.log();
          if (showToast) _showErrorMessage(LocaleKeys.share_save_failed.tr());
          return false;
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
            if (showToast) _showSuccessMessage(LocaleKeys.share_image_saved_gallery.tr());
            return true;
          } catch (e) {
            '❌ Save error: $e'.log();
            if (showToast) _showErrorMessage(LocaleKeys.share_save_failed.tr());
            return false;
          }
        } else {
          if (showToast) _showErrorMessage(LocaleKeys.share_permission_needed.tr());
          return false;
        }
      }
    } catch (e) {
      '❌ Error saving image to gallery: $e'.log();
      if (showToast) _showErrorMessage('${LocaleKeys.share_save_error.tr()}: ${e.toString()}');
      return false;
    }

    return false;
  }

  Future<void> _downloadImage() async {
    await _saveImageToGallery(showToast: true);
  }

  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFFE8F4F8), // 공유 모달 배경색
      textColor: Colors.black87,
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
                            LocaleKeys.share_store_photo.tr(),
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
                            LocaleKeys.share_my_photo.tr(),
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF19BAFF),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              LocaleKeys.share_generating_image.tr(),
                              style: const TextStyle(
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
                        : Center(
                            child: Text(
                              LocaleKeys.share_cannot_generate_image.tr(),
                              style: const TextStyle(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.share_tell_friends.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SNS공유시 이미지는 자동으로 저장될거야!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
              child: Text(
                LocaleKeys.cancel.tr(),
                style: const TextStyle(
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