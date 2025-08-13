import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/network/network.dart';

@lazySingleton
class ImageUploadService {
  final Network _network;
  final Dio _dio;

  ImageUploadService(this._network) : _dio = Dio();

  /// Upload image to S3 and return the final URL
  Future<String?> uploadCharacterImageToS3({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      '🚀 Starting S3 upload for file: $fileName'.log();
      
      // Step 1: Get presigned URL from backend
      final presignedUrlResponse = await _getPresignedUrl(fileName);
      if (presignedUrlResponse == null) {
        '❌ Failed to get presigned URL'.log();
        return null;
      }

      final presignedUrl = presignedUrlResponse['uploadUrl'] as String?;
      final finalUrl = presignedUrlResponse['fileUrl'] as String?;

      if (presignedUrl == null || finalUrl == null) {
        '❌ Invalid presigned URL response'.log();
        return null;
      }

      '📝 Got presigned URL, uploading to S3...'.log();

      // Step 2: Upload image to S3 using presigned URL
      final uploadSuccess = await _uploadToS3(presignedUrl, imageBytes);
      if (!uploadSuccess) {
        '❌ Failed to upload to S3'.log();
        return null;
      }

      '✅ Successfully uploaded to S3: $finalUrl'.log();
      return finalUrl;
    } catch (e) {
      '❌ Error in uploadCharacterImageToS3: $e'.log();
      return null;
    }
  }

  /// Get presigned URL from backend
  Future<Map<String, dynamic>?> _getPresignedUrl(String fileName) async {
    try {
      final response = await _network.post(
        'upload/presigned-url',
        {
          'fileName': fileName,
          'fileType': 'image/png',
          'folder': 'character-profiles',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      '❌ Error getting presigned URL: $e'.log();
      return null;
    }
  }

  /// Upload image bytes to S3 using presigned URL
  Future<bool> _uploadToS3(String presignedUrl, Uint8List imageBytes) async {
    try {
      final response = await _dio.put(
        presignedUrl,
        data: imageBytes,
        options: Options(
          headers: {
            'Content-Type': 'image/png',
            'Content-Length': imageBytes.length.toString(),
          },
          validateStatus: (status) => status! < 400,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      '❌ Error uploading to S3: $e'.log();
      return false;
    }
  }

  /// Upload with progress callback
  Future<String?> uploadWithProgress({
    required Uint8List imageBytes,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      '🚀 Starting S3 upload with progress for file: $fileName'.log();
      
      // Get presigned URL
      final presignedUrlResponse = await _getPresignedUrl(fileName);
      if (presignedUrlResponse == null) {
        '❌ Failed to get presigned URL'.log();
        return null;
      }

      final presignedUrl = presignedUrlResponse['uploadUrl'] as String?;
      final finalUrl = presignedUrlResponse['fileUrl'] as String?;

      if (presignedUrl == null || finalUrl == null) {
        '❌ Invalid presigned URL response'.log();
        return null;
      }

      // Upload with progress tracking
      final response = await _dio.put(
        presignedUrl,
        data: Stream.fromIterable(imageBytes.map((e) => [e])),
        options: Options(
          headers: {
            'Content-Type': 'image/png',
            'Content-Length': imageBytes.length.toString(),
          },
        ),
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress?.call(progress);
          '📊 Upload progress: ${(progress * 100).toStringAsFixed(1)}%'.log();
        },
      );

      if (response.statusCode == 200) {
        '✅ Successfully uploaded to S3: $finalUrl'.log();
        return finalUrl;
      }

      return null;
    } catch (e) {
      '❌ Error in uploadWithProgress: $e'.log();
      return null;
    }
  }
}