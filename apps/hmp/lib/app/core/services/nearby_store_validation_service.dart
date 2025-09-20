import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/generated/locale_keys.g.dart';

@lazySingleton
class NearbyStoreValidationService {
  final SpaceCubit _spaceCubit;
  
  // Distance threshold in meters (50 meters)
  static const double distanceThreshold = 50.0;
  
  NearbyStoreValidationService(this._spaceCubit);
  
  /// Validates if there are any stores within the distance threshold from current location
  /// Returns list of nearby stores or empty list if none found
  Future<List<SpaceEntity>> validateNearbyStores() async {
    try {
      ('🔍 Starting nearby store validation...').log();
      
      // 1. Get current location with high accuracy
      final Position currentPosition = await _getCurrentLocation();
      
      ('📍 Current position: ${currentPosition.latitude}, ${currentPosition.longitude}').log();
      ('🎯 GPS accuracy: ${currentPosition.accuracy}m').log();
      
      // 2. Get all available stores
      final stores = _spaceCubit.state.spaceList;
      
      if (stores.isEmpty) {
        ('⚠️ No stores available in state').log();
        return [];
      }
      
      ('🏪 Total stores to check: ${stores.length}').log();
      
      // 3. Filter stores within distance threshold
      final nearbyStores = <SpaceEntity>[];
      
      for (final store in stores) {
        if (store.latitude != 0 && store.longitude != 0) {
          final distance = Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            store.latitude,
            store.longitude,
          );
          
          ('📏 Distance to ${store.name}: ${distance.toStringAsFixed(1)}m').log();
          
          if (distance <= distanceThreshold) {
            nearbyStores.add(store);
            ('✅ ${store.name} is within range (${distance.toStringAsFixed(1)}m)').log();
          }
        }
      }
      
      ('🎯 Found ${nearbyStores.length} nearby stores').log();
      
      return nearbyStores;
      
    } catch (e) {
      ('❌ Error validating nearby stores: $e').log();
      return [];
    }
  }
  
  // Cache for recent location
  static Position? _cachedPosition;
  static DateTime? _cacheTime;
  static const Duration _cacheValidDuration = Duration(seconds: 30);
  
  /// Gets current location with high accuracy and retries on failure
  Future<Position> _getCurrentLocation() async {
    // Check if we have a valid cached position
    if (_cachedPosition != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheValidDuration) {
      ('📍 Using cached position (${DateTime.now().difference(_cacheTime!).inSeconds}s old)').log();
      return _cachedPosition!;
    }
    
    // Check location services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(LocaleKeys.location_services_disabled.tr());
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(LocaleKeys.location_permissions_denied.tr());
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(LocaleKeys.location_permissions_permanently_denied.tr());
    }
    
    // Get position with high accuracy
    Position? finalPosition;
    int retryCount = 0;
    const maxRetries = 3;
    
    while (finalPosition == null && retryCount < maxRetries) {
      try {
        retryCount++;
        ('🔄 Location attempt $retryCount/$maxRetries').log();
        
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: retryCount == 1 ? LocationAccuracy.high : 
                          retryCount == 2 ? LocationAccuracy.best : 
                          LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10 + (retryCount * 5)),
        );
        
        // Accept position if accuracy is reasonable (adjusted threshold)
        if (position.accuracy <= 50) {  // Increased from 20m to 50m
          ('✅ Good GPS accuracy: ${position.accuracy}m').log();
          finalPosition = position;
        } else if (retryCount >= maxRetries) {
          ('⚠️ Accepting position with accuracy: ${position.accuracy}m').log();
          finalPosition = position;
        } else {
          ('⚠️ GPS accuracy poor (${position.accuracy}m), retrying...').log();
          await Future.delayed(const Duration(seconds: 2));
        }
        
      } catch (e) {
        ('❌ Location attempt $retryCount failed: $e').log();
        
        if (retryCount >= maxRetries) {
          // Final fallback - try to get any position
          try {
            finalPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5),
            );
            ('⚠️ Using fallback position with accuracy: ${finalPosition.accuracy}m').log();
          } catch (fallbackError) {
            ('❌ All location attempts failed').log();
            throw Exception('Unable to get current location after $maxRetries attempts');
          }
        } else {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    
    if (finalPosition != null) {
      // Cache the position
      _cachedPosition = finalPosition;
      _cacheTime = DateTime.now();
      return finalPosition;
    }
    
    throw Exception('Failed to get location');
  }
  
  /// Finds the closest store from the given list
  SpaceEntity? findClosestStore(List<SpaceEntity> nearbyStores, Position currentPosition) {
    if (nearbyStores.isEmpty) return null;
    
    SpaceEntity? closestStore;
    double minDistance = double.infinity;
    
    for (final store in nearbyStores) {
      if (store.latitude != 0 && store.longitude != 0) {
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          store.latitude,
          store.longitude,
        );
        
        if (distance < minDistance) {
          minDistance = distance;
          closestStore = store;
        }
      }
    }
    
    if (closestStore != null) {
      ('🎯 Closest store: ${closestStore.name} (${minDistance.toStringAsFixed(1)}m)').log();
    }
    
    return closestStore;
  }
  
  /// Gets a user-friendly error message based on the validation result
  String getValidationErrorMessage(List<SpaceEntity> nearbyStores) {
    if (nearbyStores.isEmpty) {
      return LocaleKeys.move_to_nearby_store.tr();
    }
    return '';
  }
}