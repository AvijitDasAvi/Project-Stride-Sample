import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_stride_sample/service/location_service.dart';

class ClimbController extends GetxController with GetTickerProviderStateMixin {
  final locationService = LocationService();

  final RxDouble totalElevation = 0.0.obs;
  final RxList<double> altitudeRoute = <double>[].obs;
  final RxBool isTracking = false.obs;
  final RxInt floorCount = 0.obs;
  late AnimationController animationController;
  final RxDouble offset = 0.0.obs;
  double scrollSpeed = 50.0;
  late AudioPlayer audioPlayer;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    );
    audioPlayer = AudioPlayer();
    audioPlayer.setSource(AssetSource('music/Elevator.wav'));
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

  StreamSubscription<Position>? _positionSub;
  double? _lastAltitude;

  static const double minAltitudeThreshold = 0.5;

  void startClimbTracking() async {
    audioPlayer.setSource(AssetSource('music/Elevator.wav'));
    audioPlayer.resume();
    if (!animationController.isAnimating) {
      animationController.repeat();
    }
    bool permissionGranted = await locationService.ensurePermission();
    if (!permissionGranted) {
      Get.snackbar("Permission Denied", "Location permission is required.");
      if (kDebugMode) print("❌ Location permission not granted.");
      return;
    }

    if (kDebugMode) print('✅ Location permission granted');

    await _positionSub?.cancel();

    _positionSub = locationService.getPositionStream().listen((position) {
      double currentAltitude = position.altitude;

      if (_lastAltitude == null) {
        _lastAltitude = currentAltitude;
        altitudeRoute.add(currentAltitude);
        if (kDebugMode) {
          print('📍 First altitude: ${currentAltitude.toStringAsFixed(2)} m');
        }
        return;
      }

      double diff = currentAltitude - _lastAltitude!;
      if (diff.abs() >= minAltitudeThreshold) {
        totalElevation.value += diff.abs();
        _lastAltitude = currentAltitude;
        altitudeRoute.add(currentAltitude);
        countFloor();

        if (kDebugMode) {
          print('⛰️ Altitude: ${currentAltitude.toStringAsFixed(2)} m');
          print('⬆️ Gained: ${diff.toStringAsFixed(2)} m');
          print(
            '📏 Total elevation: ${totalElevation.value.toStringAsFixed(2)} m',
          );
          print('🏢 Estimated floors: ${floorCount.value}');
        }
      } else {
        if (kDebugMode) {
          print(
            '⚠️ Ignored minor altitude change: ${diff.toStringAsFixed(2)} m',
          );
        }
      }
    });

    isTracking.value = true;
  }

  void countFloor() {
    floorCount.value = ((totalElevation.value / 2.4384) / 2).floor();
  }

  void stopClimbTracking() async {
    await audioPlayer.stop();
    _positionSub?.cancel();
    animationController.stop();
    _positionSub = null;
    isTracking.value = false;
  }

  void resetClimbTracking() {
    stopClimbTracking();
    totalElevation.value = 0.0;
    altitudeRoute.clear();
    _lastAltitude = null;
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    stopClimbTracking();
    animationController.dispose();
    super.onClose();
  }
}
