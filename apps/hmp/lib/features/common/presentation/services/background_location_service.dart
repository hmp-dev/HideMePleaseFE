import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/background_location_permission_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class BackgroundLocationService {
  static const String _hasShownDialogKey = 'has_shown_background_location_dialog';
  static const String _lastRequestDateKey = 'last_background_location_request_date';
  static const int _daysBeforeReask = 7; // Days to wait before asking again

  /// Checks and requests background location permission if needed
  static Future<void> checkAndRequestBackgroundLocation(BuildContext context) async {
    try {
      '🔔 BackgroundLocationService: Starting check...'.log();
      print('🔔 BackgroundLocationService: Starting check...');

      final locationCubit = getIt<EnableLocationCubit>();
      final prefs = await SharedPreferences.getInstance();

      // For Android, we need to check if we have at least whileInUse permission first
      if (Platform.isAndroid) {
        '🔔 Platform: Android'.log();
        print('🔔 Platform: Android');
        final currentPermission = await Geolocator.checkPermission();
        '🔔 Current permission: $currentPermission'.log();
        print('🔔 Current permission: $currentPermission');

        // If we don't have any location permission, request basic permission first
        if (currentPermission == LocationPermission.denied ||
            currentPermission == LocationPermission.unableToDetermine) {
          '🔔 Basic location permission not granted, requesting basic permission first'.log();
          final basicPermission = await Geolocator.requestPermission();
          if (basicPermission == LocationPermission.denied ||
              basicPermission == LocationPermission.deniedForever) {
            '🔔 User denied basic location permission'.log();
            return;
          }
        } else if (currentPermission == LocationPermission.deniedForever) {
          '🔔 Location permission permanently denied'.log();
          return;
        }

        // On Android 10+ (API 29+), background location needs special handling
        // Check if we already have background (always) permission
        if (currentPermission == LocationPermission.always) {
          '🔔 Background location permission already granted'.log();
          return;
        }

        '🔔 Android: Need to request background permission'.log();
      } else {
        '🔔 Platform: iOS'.log();
        print('🔔 Platform: iOS');
        // iOS logic
        final hasBackgroundPermission = await locationCubit.isBackgroundLocationGranted();
        print('🔔 Has background permission: $hasBackgroundPermission');
        if (hasBackgroundPermission) {
          '🔔 Background location permission already granted'.log();
          print('🔔 Background location permission already granted');
          return;
        }

        // Check if we have basic location permission first
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.unableToDetermine) {
          '🔔 Basic location permission not granted, requesting it first'.log();
          // Request basic location permission first
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            '🔔 User denied basic location permission'.log();
            return;
          }
        } else if (permission == LocationPermission.deniedForever) {
          '🔔 Location permission permanently denied'.log();
          return;
        }

        '🔔 iOS: Need to request background permission'.log();
      }

      // Check if we should show the dialog
      if (!_shouldShowDialog(prefs)) {
        '🔔 Skipping background location dialog based on user preferences'.log();
        return;
      }

      '🔔 Will show custom dialog'.log();

      // Show custom explanation dialog for both platforms
      if (!context.mounted) return;

      '🔔 Showing BackgroundLocationPermissionDialog...'.log();
      final userAccepted = await BackgroundLocationPermissionDialog.show(context);
      '🔔 Dialog result: $userAccepted'.log();

      if (userAccepted == true) {
        // User accepted, request system permission
        'User accepted background location explanation, requesting system permission'.log();

        bool granted = false;

        if (Platform.isAndroid) {
          // On Android, requesting permission again will prompt for "Allow all the time"
          // This only works on Android 10+ (API 29+)
          final permission = await Geolocator.requestPermission();
          granted = permission == LocationPermission.always;

          // Update the cubit state
          await locationCubit.requestBackgroundLocationPermission();

          // Request battery optimization exclusion to prevent Doze mode from killing the service
          await requestBatteryOptimizationExclusion();
        } else {
          // iOS - need to open settings for background permission
          print('🔔 iOS: Opening app settings for background location permission');
          await openAppSettings();

          // We can't immediately check if permission was granted since the user
          // needs to manually enable it in settings
          // Just mark as shown so we don't ask again immediately
          granted = false;
        }

        if (granted) {
          'Background location permission granted'.log();
        } else if (Platform.isAndroid) {
          'Background location permission denied'.log();
        } else {
          'iOS: User directed to settings for background location'.log();
        }

        // Mark dialog as shown and update last request date
        await prefs.setBool(_hasShownDialogKey, true);
        await prefs.setString(_lastRequestDateKey, DateTime.now().toIso8601String());
      } else {
        // User declined, mark as shown and set last request date
        'User declined background location explanation'.log();
        await prefs.setBool(_hasShownDialogKey, true);
        await prefs.setString(_lastRequestDateKey, DateTime.now().toIso8601String());
      }
    } catch (e) {
      'Error checking/requesting background location: $e'.log();
    }
  }

  /// Determines if we should show the background location dialog
  static bool _shouldShowDialog(SharedPreferences prefs) {
    // Check if user has permanently dismissed the dialog
    final hasShownDialog = prefs.getBool(_hasShownDialogKey) ?? false;
    if (hasShownDialog) {
      // Check if enough time has passed to ask again
      final lastRequestDateStr = prefs.getString(_lastRequestDateKey);
      if (lastRequestDateStr != null) {
        final lastRequestDate = DateTime.parse(lastRequestDateStr);
        final daysSinceLastRequest = DateTime.now().difference(lastRequestDate).inDays;

        // Only show again if enough days have passed
        return daysSinceLastRequest >= _daysBeforeReask;
      }
    }

    return true; // Show dialog if never shown before
  }

  /// Resets the dialog preferences (for testing or settings)
  static Future<void> resetDialogPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasShownDialogKey);
    await prefs.remove(_lastRequestDateKey);
  }

  /// Requests battery optimization exclusion for Android
  /// This prevents the system from putting the app into Doze mode
  /// which would stop background location tracking after 10 minutes
  static Future<void> requestBatteryOptimizationExclusion() async {
    if (!Platform.isAndroid) return;

    try {
      '🔋 Checking battery optimization status...'.log();

      // Check if battery optimization permission is available
      final status = await Permission.ignoreBatteryOptimizations.status;

      if (status.isDenied) {
        '🔋 Requesting battery optimization exclusion...'.log();

        // Request permission to ignore battery optimizations
        final result = await Permission.ignoreBatteryOptimizations.request();

        if (result.isGranted) {
          '✅ Battery optimization exclusion granted'.log();
        } else {
          '❌ Battery optimization exclusion denied'.log();
        }
      } else if (status.isGranted) {
        '✅ Battery optimization already excluded'.log();
      }
    } catch (e) {
      '❌ Error requesting battery optimization exclusion: $e'.log();
    }
  }
}