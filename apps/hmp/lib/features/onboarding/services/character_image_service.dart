import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character_profile.dart';

class CharacterImageService {
  static const int imageSize = 512;

  /// Merge character layers into a single image
  static Future<Uint8List?> mergeCharacterLayers(CharacterProfile character) async {
    try {
      // Create a picture recorder
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromPoints(
          const Offset(0, 0),
          Offset(imageSize.toDouble(), imageSize.toDouble()),
        ),
      );

      // Load and draw each layer in order
      final layers = [
        character.background,
        character.body,
        character.clothes,
        character.hair,
        if (character.earAccessory != null) character.earAccessory!,
        character.eyes,
        character.nose,
      ];

      for (final layerPath in layers) {
        final image = await _loadAssetImage(layerPath);
        if (image != null) {
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(0, 0, imageSize.toDouble(), imageSize.toDouble()),
            Paint()..filterQuality = FilterQuality.high,
          );
        }
      }

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(imageSize, imageSize);
      
      // Convert to PNG bytes
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error merging character layers: $e');
      return null;
    }
  }

  /// Load an asset image as ui.Image
  static Future<ui.Image?> _loadAssetImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: imageSize,
        targetHeight: imageSize,
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('Error loading asset image $assetPath: $e');
      return null;
    }
  }

  /// Generate a unique filename for the merged image
  static String generateFileName(String characterId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'character_${characterId}_$timestamp.png';
  }

  /// Convert CharacterProfile from JSON string
  static CharacterProfile? characterFromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    
    try {
      final json = jsonDecode(jsonString);
      return CharacterProfile.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing character JSON: $e');
      return null;
    }
  }
}