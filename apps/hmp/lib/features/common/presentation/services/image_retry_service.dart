import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';

class ImageRetryService {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 1);
  static const double backoffMultiplier = 1.2;

  // Fast validation for onboarding
  static const int onboardingMaxRetries = 2;
  static const Duration onboardingInitialDelay = Duration(milliseconds: 500);

  /// Validates if an image URL is accessible and returns valid image data
  /// with retry logic for handling server-side image generation delays
  static Future<bool> validateImageWithRetry(String imageUrl, {bool isOnboarding = false}) async {
    if (imageUrl.isEmpty) {
      '❌ [ImageRetryService] Empty URL provided'.log();
      return false;
    }

    // Use different settings for onboarding
    final maxAttempts = isOnboarding ? onboardingMaxRetries : maxRetries;
    final baseDelay = isOnboarding ? onboardingInitialDelay : initialDelay;

    '🔄 [ImageRetryService] Starting validation for: $imageUrl (onboarding: $isOnboarding)'.log();

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        // Calculate delay with exponential backoff
        if (attempt > 0) {
          final delay = Duration(
            milliseconds: (baseDelay.inMilliseconds *
                         (backoffMultiplier * attempt)).round(),
          );
          '⏳ [ImageRetryService] Attempt ${attempt + 1}/$maxAttempts - Waiting ${delay.inMilliseconds}ms before retry'.log();
          await Future.delayed(delay);
        }

        '🔍 [ImageRetryService] Attempt ${attempt + 1}/$maxAttempts - Validating image...'.log();

        // Try to load the image
        final image = NetworkImage(imageUrl);
        final completer = Completer<bool>();

        final stream = image.resolve(const ImageConfiguration());

        late final ImageStreamListener listener;
        listener = ImageStreamListener(
          (ImageInfo info, bool call) {
            '✅ [ImageRetryService] Image loaded successfully on attempt ${attempt + 1}'.log();
            stream.removeListener(listener);
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onError: (error, stackTrace) {
            if (attempt < maxAttempts - 1) {
              '⚠️ [ImageRetryService] Attempt ${attempt + 1} failed: $error'.log();
              stream.removeListener(listener);
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            } else {
              '❌ [ImageRetryService] Final attempt failed: $error'.log();
              stream.removeListener(listener);
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          },
        );

        stream.addListener(listener);

        // Wait for result with timeout (shorter for onboarding)
        final timeoutDuration = isOnboarding ? const Duration(seconds: 3) : const Duration(seconds: 5);
        final result = await completer.future.timeout(
          timeoutDuration,
          onTimeout: () {
            '⏱️ [ImageRetryService] Timeout on attempt ${attempt + 1} after ${timeoutDuration.inSeconds}s'.log();
            stream.removeListener(listener);
            return false;
          },
        );

        if (result) {
          return true;
        }

        // If this was not the last attempt and it failed, continue to retry
        if (attempt < maxRetries - 1) {
          continue;
        }

      } catch (e) {
        '❌ [ImageRetryService] Exception on attempt ${attempt + 1}: $e'.log();
        if (attempt >= maxRetries - 1) {
          return false;
        }
      }
    }

    '❌ [ImageRetryService] All retry attempts exhausted'.log();
    return false;
  }

  /// Loads an image with retry logic, returning a widget
  static Widget loadImageWithRetry({
    required String url,
    double? height,
    double? width,
    BoxFit? fit,
    String placeHolder = 'assets/images/place_holder_card.png',
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) {
    return _RetryImageWidget(
      url: url,
      height: height,
      width: width,
      fit: fit,
      placeHolder: placeHolder,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

class _RetryImageWidget extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String placeHolder;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const _RetryImageWidget({
    required this.url,
    this.height,
    this.width,
    this.fit,
    required this.placeHolder,
    this.onSuccess,
    this.onError,
  });

  @override
  State<_RetryImageWidget> createState() => _RetryImageWidgetState();
}

class _RetryImageWidgetState extends State<_RetryImageWidget> {
  int _retryCount = 0;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _loadImage() {
    if (_retryCount >= ImageRetryService.maxRetries) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      widget.onError?.call();
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    '🔄 [RetryImageWidget] Loading image attempt ${_retryCount + 1}/${ImageRetryService.maxRetries}: ${widget.url}'.log();
  }

  void _scheduleRetry() {
    if (_retryCount >= ImageRetryService.maxRetries - 1) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      widget.onError?.call();
      return;
    }

    final delay = Duration(
      milliseconds: (ImageRetryService.initialDelay.inMilliseconds *
                   (ImageRetryService.backoffMultiplier * (_retryCount + 1))).round(),
    );

    '⏳ [RetryImageWidget] Scheduling retry ${_retryCount + 2}/${ImageRetryService.maxRetries} in ${delay.inSeconds}s'.log();

    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      _retryCount++;
      _loadImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Image.asset(
        widget.placeHolder,
        height: widget.height,
        width: widget.width,
        fit: widget.fit ?? BoxFit.cover,
      );
    }

    return Image.network(
      widget.url,
      height: widget.height,
      width: widget.width,
      fit: widget.fit ?? BoxFit.cover,
      headers: const {
        'Accept': 'image/*',
        'User-Agent': 'HideMePlease/1.0',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Image loaded successfully
          if (_isLoading) {
            _isLoading = false;
            '✅ [RetryImageWidget] Image loaded successfully on attempt ${_retryCount + 1}'.log();
            widget.onSuccess?.call();
          }
          return child;
        }
        return Center(
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2.5,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        '❌ [RetryImageWidget] Error on attempt ${_retryCount + 1}: $error'.log();

        // Schedule retry if we haven't exceeded max attempts
        if (_retryCount < ImageRetryService.maxRetries - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scheduleRetry();
          });

          // Show loading indicator while waiting for retry
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                const SizedBox(height: 8),
                Text(
                  'Retrying... (${_retryCount + 1}/${ImageRetryService.maxRetries})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Max retries reached, show placeholder
        return Image.asset(
          widget.placeHolder,
          height: widget.height,
          width: widget.width,
          fit: widget.fit ?? BoxFit.cover,
        );
      },
    );
  }
}