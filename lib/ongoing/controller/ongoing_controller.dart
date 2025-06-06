import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_stride_sample/service/location_service.dart';

class OngoingController extends GetxController
    with GetTickerProviderStateMixin {
  final locationService = LocationService();

  final RxDouble totalDistance = 0.0.obs;
  final RxInt steps = 0.obs;
  final RxList<Position> route = <Position>[].obs;
  final RxBool isTracking = false.obs;
  late AnimationController animationController;
  final RxDouble offset = 0.0.obs;
  double scrollSpeed = 50.0;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    );

    animationController.addListener(() {
      final elapsed =
          animationController.lastElapsedDuration?.inMilliseconds ?? 0;
      offset.value = (elapsed / 1000) * scrollSpeed;
    });
  }

  void setScrollSpeed(double imageWidth, double seconds) {
    scrollSpeed = imageWidth / seconds;
    update();
  }

  void start() {
    if (!animationController.isAnimating) {
      animationController.repeat();
    }
  }

  void stop() {
    animationController.stop();
  }

  StreamSubscription<Position>? _positionSub;
  Position? _lastPosition;

  static const double minDistanceThreshold = 0.5;
  static const double maxDistanceThreshold = 30.0;
  static const double maxAllowedAccuracy = 20.0;
  static const double averageStepLength = 0.75;

  static const double minSpeedThreshold = 0.5;

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
            print(
              '📍 First position recorded: ${position.latitude}, ${position.longitude}',
            );
          }
          return;
        }

        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        final timeDiff =
            position.timestamp.difference(_lastPosition!.timestamp).inSeconds;

        final speed = timeDiff > 0 ? distance / timeDiff : 0; // Updated line

        if (distance > minDistanceThreshold &&
            distance < maxDistanceThreshold &&
            speed > minSpeedThreshold) {
          totalDistance.value += distance;
          steps.value = (totalDistance.value / averageStepLength).round();
          _lastPosition = position;
          route.add(position);

          if (kDebugMode) {
            print(
              '📍 New position: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)',
            );
            print('➕ Added distance: ${distance.toStringAsFixed(2)} m');
            print(
              '📏 Total distance: ${totalDistance.value.toStringAsFixed(2)} m',
            );
            print('👣 Estimated steps: ${steps.value}');
            print('🚶 Speed: ${speed.toStringAsFixed(2)} m/s');
          }
        } else {
          if (kDebugMode) {
            print(
              '⚠️ Ignored small/large jump or low speed: distance=$distance m, speed=${speed.toStringAsFixed(2)} m/s',
            );
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
    animationController.dispose();
    stopTracking();
    super.onClose();
  }
}
