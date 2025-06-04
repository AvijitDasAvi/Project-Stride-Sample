import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_stride_sample/ongoing/service/location_service.dart';

class OngoingController extends GetxController {
  final locationService = LocationService();

  final RxDouble totalDistance = 0.0.obs;
  final RxInt steps = 0.obs;
  final RxList<Position> route = <Position>[].obs;
  final RxBool isTracking = false.obs;

  StreamSubscription<Position>? _positionSub;
  Position? _lastPosition;

  static const double minDistanceThreshold = 0.5;   
  static const double maxDistanceThreshold = 30.0;  
  static const double maxAllowedAccuracy = 20.0;    

  void startTracking() async {
    bool permissionGranted = await locationService.ensurePermission();
    if (!permissionGranted) {
      Get.snackbar("Permission Denied", "Location permission is required.");
      if (kDebugMode) {
        print("❌ Location permission not granted.");
      }
      return;
    }

    if (kDebugMode) {
      print('✅ Location permission granted');
    }

    await _positionSub?.cancel();

    _positionSub = locationService.getPositionStream().listen(
      (position) {
        if (position.accuracy >= maxAllowedAccuracy) {
          if (kDebugMode) {
            print('⚠️ Ignored due to poor accuracy: ${position.accuracy} m');
          }
          return;
        }

        if (DateTime.now().difference(position.timestamp).inSeconds > 5) {
          if (kDebugMode) {
            print('⚠️ Ignored stale GPS: ${position.timestamp}');
          }
          return;
        }

        if (_lastPosition == null) {
          _lastPosition = position;
          route.add(position);
          if (kDebugMode) {
            print('📍 First position recorded: ${position.latitude}, ${position.longitude}');
          }
          return;
        }

        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance > minDistanceThreshold && distance < maxDistanceThreshold) {
          totalDistance.value += distance;
          steps.value = (totalDistance.value / 0.75).round();
          _lastPosition = position;
          route.add(position);

          if (kDebugMode) {
            print('📍 New position: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)');
            print('➕ Added distance: ${distance.toStringAsFixed(2)} m');
            print('📏 Total distance: ${totalDistance.value.toStringAsFixed(2)} m');
            print('👣 Estimated steps: ${steps.value}');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ Ignored small or large jump: $distance meters');
          }
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("❌ Error in position stream: $e");
        }
      },
    );

    isTracking.value = true;
  }

  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    isTracking.value = false;
  }

  void resetTracking() {
    stopTracking();
    totalDistance.value = 0.0;
    steps.value = 0;
    route.clear();
    _lastPosition = null;
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}
