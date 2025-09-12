import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:mobile/app/core/injection/injection.dart';

@lazySingleton
class CheckInLocationService {
  final SpaceCubit _spaceCubit;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _periodicCheckTimer;
  
  // Distance threshold in meters (50 meters)
  static const double distanceThreshold = 50.0;
  
  CheckInLocationService(this._spaceCubit);
  
  void startLocationTracking() {
    print('🚀 Starting location tracking service (background enabled)');
    
    // Cancel any existing subscriptions
    stopLocationTracking();
    
    // Get current state to check if user is checked in
    final state = _spaceCubit.state;
    if (state.currentCheckedInSpaceId == null || 
        state.checkInLatitude == null || 
        state.checkInLongitude == null) {
      print('📍 No active check-in, skipping location tracking');
      return;
    }
    
    print('📍 Check-in detected at: ${state.checkInLatitude}, ${state.checkInLongitude}');
    print('🏪 Space ID: ${state.currentCheckedInSpaceId}');
    print('⏱️ Starting 3-minute periodic checks + real-time tracking');
    
    // Start periodic location checking every 3 minutes
    _periodicCheckTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => _checkCurrentLocation(),
    );
    
    // 즉시 첫 하트비트 전송 (체크인 직후 바로 실행)
    print('💓 Sending first heartbeat immediately after check-in');
    _checkCurrentLocation();
    
    // Also listen to continuous position updates for immediate response
    _startPositionStream();
  }
  
  void _startPositionStream() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permission permanently denied');
        return;
      }
      
      // Configure location settings with background support
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Minimum distance change in meters to trigger update
        // timeLimit is optional - removes location updates after specified duration
        // Keeping it null for continuous tracking
      );
      
      // Start listening to position updates
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _checkDistance(position);
        },
        onError: (error) {
          print('❌ Location stream error: $error');
        },
      );
      
      print('✅ Position stream started');
    } catch (e) {
      print('❌ Failed to start position stream: $e');
    }
  }
  
  Future<void> _checkCurrentLocation() async {
    try {
      final state = _spaceCubit.state;
      
      // Check if still checked in
      if (state.currentCheckedInSpaceId == null || 
          state.checkInLatitude == null || 
          state.checkInLongitude == null) {
        print('📍 No active check-in, stopping location tracking');
        stopLocationTracking();
        return;
      }
      
      // Get current position
      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Send heartbeat to server
      try {
        final spaceRemoteDataSource = getIt<SpaceRemoteDataSource>();
        await spaceRemoteDataSource.sendCheckInHeartbeat(
          spaceId: state.currentCheckedInSpaceId!,
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
        );
        print('💓 Heartbeat sent successfully');
      } catch (e) {
        print('❌ Failed to send heartbeat: $e');
        // Continue with distance check even if heartbeat fails
      }
      
      _checkDistance(currentPosition);
    } catch (e) {
      print('❌ Error checking current location: $e');
    }
  }
  
  void _checkDistance(Position currentPosition) {
    final state = _spaceCubit.state;
    
    if (state.currentCheckedInSpaceId == null || 
        state.checkInLatitude == null || 
        state.checkInLongitude == null) {
      return;
    }
    
    // Calculate distance from check-in location
    final double distance = Geolocator.distanceBetween(
      state.checkInLatitude!,
      state.checkInLongitude!,
      currentPosition.latitude,
      currentPosition.longitude,
    );
    
    print('📏 Distance from check-in location: ${distance.toStringAsFixed(2)}m');
    print('📍 Current location: ${currentPosition.latitude}, ${currentPosition.longitude}');
    print('🎯 Check-in location: ${state.checkInLatitude}, ${state.checkInLongitude}');
    
    // Check if user has moved beyond threshold
    if (distance > distanceThreshold) {
      print('🚨 User moved beyond ${distanceThreshold}m, triggering auto check-out');
      print('⚠️ Distance exceeded: ${distance.toStringAsFixed(2)}m > ${distanceThreshold}m');
      _triggerAutoCheckOut();
    } else {
      print('✅ Within range: ${distance.toStringAsFixed(2)}m < ${distanceThreshold}m');
    }
  }
  
  void _triggerAutoCheckOut() async {
    final state = _spaceCubit.state;
    
    if (state.currentCheckedInSpaceId == null) {
      return;
    }
    
    print('🔄 Auto check-out triggered for space: ${state.currentCheckedInSpaceId}');
    
    // Stop tracking before checkout
    stopLocationTracking();
    
    // Trigger check-out
    await _spaceCubit.onCheckOut(spaceId: state.currentCheckedInSpaceId!);
    
    print('✅ Auto check-out completed');
  }
  
  void stopLocationTracking() {
    print('🛑 Stopping location tracking');
    
    _positionSubscription?.cancel();
    _positionSubscription = null;
    
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }
  
  void dispose() {
    stopLocationTracking();
  }
}