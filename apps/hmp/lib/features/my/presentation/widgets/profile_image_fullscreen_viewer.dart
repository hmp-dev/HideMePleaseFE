import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';

class ProfileImageFullscreenViewer extends StatefulWidget {
  final String? profilePartsString;
  final String? imageUrl;

  const ProfileImageFullscreenViewer({
    Key? key,
    this.profilePartsString,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<ProfileImageFullscreenViewer> createState() =>
      _ProfileImageFullscreenViewerState();
}

class _ProfileImageFullscreenViewerState
    extends State<ProfileImageFullscreenViewer> {
  final GlobalKey _imageKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 전체화면 이미지
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: RepaintBoundary(
                  key: _imageKey,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: ProfileAvatarWidget(
                        profilePartsString: widget.profilePartsString,
                        imageUrl: widget.imageUrl,
                        size: MediaQuery.of(context).size.width - 42,
                        borderRadius: 0,
                        placeholderPath: 'assets/images/profile_img.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 상단 바
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 뒤로가기 버튼
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),

                    // 저장 버튼
                    _isSaving
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _saveImage,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 이미지를 캡처
      print('🖼️  이미지 캡처 시작...');
      final boundary = _imageKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      print('🖼️  RepaintBoundary 확인: ${boundary != null}');

      final image = await boundary.toImage(pixelRatio: 3.0);
      print('🖼️  Image 생성 완료: ${image.width} x ${image.height}');

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      print('🖼️  PNG 변환 완료: ${pngBytes.length} bytes');

      // iOS는 권한 체크 없이 바로 저장 시도 (시스템이 자동으로 권한 요청)
      if (Platform.isIOS) {
        print('🍎 iOS detected, saving directly');
        try {
          await Gal.putImageBytes(
            pngBytes,
            album: 'HideMePlease',
          );
          print('💾 Image saved successfully');
          _showSuccessToast(LocaleKeys.image_saved.tr());
        } catch (e) {
          print('❌ Save error: $e');
          _showErrorToast(LocaleKeys.save_failed.tr());
        }
      } else {
        // Android는 기존 로직 유지
        print('🤖 Android detected, using Gal package');
        await Gal.putImageBytes(
          pngBytes,
          album: 'HideMePlease',
        );
        print('💾 Image saved successfully');
        _showSuccessToast(LocaleKeys.image_saved.tr());
      }
    } catch (e) {
      print('❌ 이미지 저장 실패: $e');
      _showErrorToast(LocaleKeys.save_failed.tr());
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF00A3FF),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF00A3FF),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
