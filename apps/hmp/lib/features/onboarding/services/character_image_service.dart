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
      debugPrint('🎨 Starting to merge character layers');
      debugPrint('📊 Target image size: ${imageSize}x${imageSize}');
      
      // Create a picture recorder
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

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

      debugPrint('📝 Total layers to merge: ${layers.length}');
      
      for (int i = 0; i < layers.length; i++) {
        final layerPath = layers[i];
        debugPrint('  Layer ${i + 1}: Loading $layerPath');
        final image = await _loadAssetImage(layerPath);
        if (image != null) {
          debugPrint('    ✅ Loaded: ${image.width}x${image.height}');
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(0, 0, imageSize.toDouble(), imageSize.toDouble()),
            Paint()..filterQuality = FilterQuality.high,
          );
        } else {
          debugPrint('    ⚠️ Failed to load layer: $layerPath');
        }
      }

      // Convert to image
      debugPrint('🖼️ Converting canvas to image...');
      final picture = recorder.endRecording();
      final img = await picture.toImage(imageSize, imageSize);
      
      // Convert to PNG bytes
      debugPrint('💾 Converting to PNG bytes...');
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      
      if (bytes != null) {
        debugPrint('✅ Successfully created PNG: ${bytes.length} bytes');
      } else {
        debugPrint('❌ Failed to convert to PNG bytes');
      }
      
      return bytes;
    } catch (e, stackTrace) {
      debugPrint('❌ Error merging character layers: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Load an asset image as ui.Image
  static Future<ui.Image?> _loadAssetImage(String assetPath) async {
    try {
      debugPrint('    🔄 Loading asset: $assetPath');
      final data = await rootBundle.load(assetPath);
      debugPrint('    📦 Asset loaded: ${data.lengthInBytes} bytes');
      
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: imageSize,
        targetHeight: imageSize,
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('    ❌ Error loading asset image $assetPath: $e');
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