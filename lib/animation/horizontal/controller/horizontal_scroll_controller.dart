import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HorizontalScrollController extends GetxController
    with GetTickerProviderStateMixin {
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
      final elapsed = animationController.lastElapsedDuration?.inMilliseconds ?? 0;
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

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}