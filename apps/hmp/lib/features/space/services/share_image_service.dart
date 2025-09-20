import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile/features/onboarding/models/character_profile.dart';
import 'package:mobile/features/onboarding/presentation/widgets/character_layer_widget.dart';

class ShareImageService {
  static const double imageWidth = 1080;
  static const double imageHeight = 1080;  // 정사각형으로 변경

  /// Generate share image with store photo, user profile, and check-in details
  static Future<Uint8List?> generateShareImage({
    required String storeImageUrl,
    required String storeName,
    required String userProfileImageUrl,
    String? profilePartsString,  // 레이어드 아바타 데이터
    required String userName,
    required DateTime checkInTime,
    required int hiddenTimeMinutes,
    bool isLocalImage = false,
  }) async {
    try {
      // Create a picture recorder
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(imageWidth, imageHeight);

      // Draw background (store image or local image)
      await _drawStoreBackground(canvas, size, storeImageUrl, isLocalImage);

      // Draw gradient overlay for text readability
      _drawGradientOverlay(canvas, size);

      // Draw user profile section
      await _drawUserProfile(canvas, size, userProfileImageUrl, profilePartsString, userName);

      // Draw check-in details
      _drawCheckInDetails(canvas, size, storeName, checkInTime, hiddenTimeMinutes, userName);

      // Draw HMP logo last so it appears on top
      await _drawHMPLogo(canvas, size);

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());

      // Convert to PNG bytes
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating share image: $e');
      return null;
    }
  }

  /// Draw store background image
  static Future<void> _drawStoreBackground(
      Canvas canvas, Size size, String imageUrl, bool isLocalImage) async {
    try {
      final image = isLocalImage
          ? await _loadLocalImage(imageUrl)
          : await _loadNetworkImage(imageUrl);
      if (image != null) {
        // Scale image to cover entire canvas
        final srcRect = Rect.fromLTWH(
            0, 0, image.width.toDouble(), image.height.toDouble());
        final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

        canvas.drawImageRect(
          image,
          srcRect,
          dstRect,
          Paint()..filterQuality = FilterQuality.high,
        );
      } else {
        // Fallback to solid color if image fails to load
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = const Color(0xFF1A1A1A),
        );
      }
    } catch (e) {
      // Fallback to solid color
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF1A1A1A),
      );
    }
  }

  /// Draw gradient overlay
  static void _drawGradientOverlay(Canvas canvas, Size size) {
    // Top gradient for logo area
    final topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.6),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3],
    );

    final topPaint = Paint()
      ..shader = topGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.3),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.3),
      topPaint,
    );

    // Bottom 50% gradient for better text visibility
    final bottomGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.7),
        Colors.black.withOpacity(0.85),
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final bottomPaint = Paint()
      ..shader = bottomGradient.createShader(
        Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      bottomPaint,
    );
  }

  /// Draw HMP logo
  static Future<void> _drawHMPLogo(Canvas canvas, Size size) async {
    debugPrint('Attempting to load sharelogo.png');
    try {
      final logoData = await rootBundle.load('assets/images/sharelogo.png');
      final codec = await ui.instantiateImageCodec(
        logoData.buffer.asUint8List(),
        targetHeight: 100,  // 높이 기준으로 크기 증가
      );
      final frame = await codec.getNextFrame();
      final logo = frame.image;

      debugPrint('Logo loaded successfully: ${logo.width}x${logo.height}');
      debugPrint('Canvas size: ${size.width}x${size.height}');

      // Position in top-right corner - 이미지 크기 1080x1080 기준
      final logoWidth = logo.width.toDouble();
      final logoHeight = logo.height.toDouble();
      final logoX = size.width - logoWidth - 60.0;  // 우측에서 60px 여백
      final logoY = 60.0;  // 상단에서 60px 여백

      debugPrint('Logo will be drawn at: ($logoX, $logoY) with size: ${logoWidth}x${logoHeight}');

      // Draw logo without background overlay - 배경 제거
      canvas.drawImage(logo, Offset(logoX, logoY), Paint()..filterQuality = FilterQuality.high);
      debugPrint('Logo drawn successfully at position: ($logoX, $logoY)');
    } catch (e) {
      debugPrint('Error loading share logo: $e');
      // Draw more visible text fallback
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'HIDE ME PLEASE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Colors.black,
              ),
              Shadow(
                offset: Offset(-1, -1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - textPainter.width - 60, 60));
    }
  }

  /// Draw user profile section
  static Future<void> _drawUserProfile(
      Canvas canvas, Size size, String profileImageUrl, String? profilePartsString, String userName) async {
    final bottomMargin = 380.0;  // 원래 위치
    final leftMargin = 60.0;

    // Draw profile image as square with rounded corners
    debugPrint('Loading profile image - profileParts: ${profilePartsString != null}, imageUrl: $profileImageUrl');

    ui.Image? profileImage;

    // Priority 1: Try to render layered avatar from profilePartsString
    if (profilePartsString != null && profilePartsString.isNotEmpty) {
      try {
        profileImage = await _renderLayeredAvatar(profilePartsString);
        if (profileImage != null) {
          debugPrint('Layered avatar rendered successfully');
        }
      } catch (e) {
        debugPrint('Error rendering layered avatar: $e');
      }
    }

    // Priority 2: Fall back to URL-based image
    if (profileImage == null && profileImageUrl.isNotEmpty) {
      profileImage = await _loadNetworkImage(profileImageUrl);
      if (profileImage != null) {
        debugPrint('Profile image loaded from URL successfully');
      }
    }

    try {
      if (profileImage != null) {
        // Draw square profile image with rounded corners
        final profileSize = 220.0;  // Increased size
        final profileX = leftMargin;
        final profileY = size.height - bottomMargin - profileSize;
        final radius = 30.0;

        // Create rounded rectangle clip
        canvas.save();
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(profileX, profileY, profileSize, profileSize),
          Radius.circular(radius),
        );
        canvas.clipRRect(rrect);

        // Draw profile image
        canvas.drawImageRect(
          profileImage,
          Rect.fromLTWH(0, 0, profileImage.width.toDouble(),
              profileImage.height.toDouble()),
          Rect.fromLTWH(profileX, profileY, profileSize, profileSize),
          Paint()..filterQuality = FilterQuality.high,
        );
        canvas.restore();

        // Draw white border
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      } else {
        debugPrint('Profile image is null, drawing placeholder');
        // Draw placeholder square with initial
        final profileSize = 220.0;  // Increased size
        final profileX = leftMargin;
        final profileY = size.height - bottomMargin - profileSize;
        final radius = 30.0;

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(profileX, profileY, profileSize, profileSize),
          Radius.circular(radius),
        );
        // Draw colored background
        canvas.drawRRect(
          rrect,
          Paint()..color = const Color(0xFF132E41),
        );

        // Draw user initial
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
        final initialPainter = TextPainter(
          text: TextSpan(
            text: initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        initialPainter.layout();
        initialPainter.paint(
          canvas,
          Offset(
            profileX + profileSize / 2 - initialPainter.width / 2,
            profileY + profileSize / 2 - initialPainter.height / 2,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
      // Draw placeholder square with initial
      final profileSize = 220.0;  // Increased size
      final profileX = leftMargin;
      final profileY = size.height - bottomMargin - profileSize;
      final radius = 30.0;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(profileX, profileY, profileSize, profileSize),
        Radius.circular(radius),
      );
      // Draw colored background
      canvas.drawRRect(
        rrect,
        Paint()..color = const Color(0xFF132E41),
      );

      // Draw user initial
      final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
      final initialPainter = TextPainter(
        text: TextSpan(
          text: initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      initialPainter.layout();
      initialPainter.paint(
        canvas,
        Offset(
          profileX + profileSize / 2 - initialPainter.width / 2,
          profileY + profileSize / 2 - initialPainter.height / 2,
        ),
      );
    }
  }

  /// Draw check-in details
  static void _drawCheckInDetails(Canvas canvas, Size size, String storeName,
      DateTime checkInTime, int hiddenTimeMinutes, String userName) {
    final leftMargin = 60.0;

    // Format check-in time
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedTime = timeFormat.format(checkInTime);
    final formattedDate = dateFormat.format(checkInTime);

    // Draw first line: "{userName} 님이" - 원래 위치
    final firstLinePainter = TextPainter(
      text: TextSpan(
        text: '$userName 님이',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 46,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black87,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    firstLinePainter.layout();
    firstLinePainter.paint(
      canvas,
      Offset(leftMargin, size.height - 350),  // 원래 위치로 복원
    );

    // Draw second line: "{storeName}에 숨어 있어요" - 원래 위치
    final secondLinePainter = TextPainter(
      text: TextSpan(
        text: '$storeName에 숨어 있어요',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 46,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black87,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 2,
      textWidthBasis: TextWidthBasis.parent,
    );
    secondLinePainter.layout(maxWidth: size.width - leftMargin * 2);
    secondLinePainter.paint(
      canvas,
      Offset(leftMargin, size.height - 290),  // 원래 위치로 복원
    );

    // Draw Hidden Time label - 아래로 이동
    final hiddenTimeLabelPainter = TextPainter(
      text: const TextSpan(
        text: 'Hidden Time',
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black87,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    hiddenTimeLabelPainter.layout();
    hiddenTimeLabelPainter.paint(
      canvas,
      Offset(leftMargin, size.height - 170),  // 더 아래로 이동
    );

    // Draw date and time in larger size - 아래로 이동
    final dateTimePainter = TextPainter(
      text: TextSpan(
        text: '$formattedDate  $formattedTime',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 52,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black87,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    dateTimePainter.layout();
    dateTimePainter.paint(
      canvas,
      Offset(leftMargin, size.height - 120),  // 더 아래로 이동
    );
  }

  /// Load network image
  static Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final codec = await ui.instantiateImageCodec(response.bodyBytes);
        final frame = await codec.getNextFrame();
        return frame.image;
      }
    } catch (e) {
      debugPrint('Error loading network image: $e');
    }
    return null;
  }

  /// Load local image
  static Future<ui.Image?> _loadLocalImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        return frame.image;
      }
    } catch (e) {
      debugPrint('Error loading local image: $e');
    }
    return null;
  }

  /// Render layered avatar to ui.Image
  static Future<ui.Image?> _renderLayeredAvatar(String profilePartsString) async {
    try {
      debugPrint('Starting layered avatar rendering');

      // Parse the profile parts
      final characterData = jsonDecode(profilePartsString);
      final character = CharacterProfile.fromJson(characterData);

      // Create a recorder for the avatar
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = 512.0; // High resolution for quality

      // Helper function to load and draw an asset
      Future<void> drawAssetLayer(String assetPath) async {
        if (assetPath.isEmpty) return;

        try {
          final data = await rootBundle.load(assetPath);
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
            targetWidth: size.toInt(),
            targetHeight: size.toInt(),
          );
          final frame = await codec.getNextFrame();
          final image = frame.image;

          canvas.drawImageRect(
            image,
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(0, 0, size, size),
            Paint()..filterQuality = FilterQuality.high,
          );
        } catch (e) {
          debugPrint('Failed to load layer $assetPath: $e');
        }
      }

      // Draw layers in order
      await drawAssetLayer(character.background);
      await drawAssetLayer(character.body);
      await drawAssetLayer(character.clothes);
      await drawAssetLayer(character.hair);
      if (character.earAccessory != null && character.earAccessory!.isNotEmpty) {
        await drawAssetLayer(character.earAccessory!);
      }
      await drawAssetLayer(character.eyes);
      await drawAssetLayer(character.nose);

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());

      debugPrint('Layered avatar rendered successfully: ${img.width}x${img.height}');
      return img;
    } catch (e) {
      debugPrint('Error rendering layered avatar: $e');
      return null;
    }
  }

  /// Create a widget-based share image (alternative method)
  static Future<Uint8List?> generateShareImageFromWidget({
    required GlobalKey repaintBoundaryKey,
  }) async {
    try {
      RenderRepaintBoundary? boundary = repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating share image from widget: $e');
      return null;
    }
  }
}