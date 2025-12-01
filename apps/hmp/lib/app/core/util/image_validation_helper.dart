import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// 네트워크 이미지 로딩 시 데이터 검증을 위한 헬퍼 클래스
class ImageValidationHelper {
  /// HTTP 응답으로부터 안전하게 이미지를 로드합니다.
  ///
  /// [url] - 이미지 URL
  /// [headers] - HTTP 헤더 (선택사항)
  ///
  /// Returns: ui.Image 또는 null (실패 시)
  ///
  /// 검증 항목:
  /// - HTTP 상태 코드 확인
  /// - Content-Type이 image/*인지 확인
  /// - 응답 바이트가 비어있지 않은지 확인 (최소 100 bytes)
  /// - 이미지 코덱 생성 시 예외 처리
  static Future<ui.Image?> loadNetworkImageSafely({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('[ImageValidation] Loading image from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      // HTTP 상태 코드 확인
      if (response.statusCode != 200) {
        debugPrint(
          '[ImageValidation] Failed to load image. '
          'Status code: ${response.statusCode}, URL: $url'
        );
        return null;
      }

      // Content-Type 확인
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().startsWith('image/')) {
        debugPrint(
          '[ImageValidation] Invalid content-type: $contentType, URL: $url'
        );
        return null;
      }

      // 응답 바이트 검증
      final bodyBytes = response.bodyBytes;
      if (bodyBytes.isEmpty || bodyBytes.length < 100) {
        debugPrint(
          '[ImageValidation] Response body too small: ${bodyBytes.length} bytes, URL: $url'
        );
        return null;
      }

      debugPrint(
        '[ImageValidation] Valid image data received: '
        '${bodyBytes.length} bytes, content-type: $contentType'
      );

      // 이미지 코덱 생성 (예외 처리)
      return await _instantiateImageCodecSafely(bodyBytes, url);

    } catch (e, stackTrace) {
      debugPrint('[ImageValidation] Error loading image from $url: $e');
      debugPrint('[ImageValidation] Stack trace: $stackTrace');
      return null;
    }
  }

  /// 바이트 데이터로부터 안전하게 이미지 코덱을 생성합니다.
  static Future<ui.Image?> _instantiateImageCodecSafely(
    Uint8List bytes,
    String url,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      debugPrint('[ImageValidation] Successfully created image codec for: $url');
      return frame.image;
    } catch (e, stackTrace) {
      debugPrint(
        '[ImageValidation] Failed to instantiate image codec for $url: $e'
      );
      debugPrint('[ImageValidation] Stack trace: $stackTrace');
      return null;
    }
  }

  /// 바이트 데이터의 유효성을 검증합니다 (이미지 매직 바이트 확인).
  ///
  /// 지원 포맷: PNG, JPEG, GIF, WebP, BMP
  static bool validateImageBytes(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length < 4) {
      return false;
    }

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }

    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return true;
    }

    // WebP: 52 49 46 46 (RIFF)
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }

    // BMP: 42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return true;
    }

    return false;
  }
}
