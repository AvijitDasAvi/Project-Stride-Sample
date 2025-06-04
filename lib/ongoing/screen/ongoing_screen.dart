// lib/ongoing/view/ongoing_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_stride_sample/ongoing/controller/ongoing_controller.dart';

class OngoingScreen extends StatelessWidget {
  final OngoingController ongoingController = Get.put(OngoingController());

  OngoingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GPS Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final route = ongoingController.route;
          final isTracking = ongoingController.isTracking.value;
          final currentPosition = route.isNotEmpty ? route.last : null;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Distance:",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Total steps:",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${ongoingController.totalDistance.value.toStringAsFixed(2)} meters",
                    style: const TextStyle(fontSize: 24),
                  ),
                  Obx(
                    () => Text(
                      "${ongoingController.steps.value} Steps",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (currentPosition != null) ...[
                Text(
                  "Current Location:",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Lat: ${currentPosition.latitude.toStringAsFixed(5)}, "
                  "Lng: ${currentPosition.longitude.toStringAsFixed(5)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isTracking ? null : ongoingController.startTracking,
                child: const Text("Start Tracking"),
              ),
              ElevatedButton(
                onPressed: isTracking ? ongoingController.stopTracking : null,
                child: const Text("Stop Tracking"),
              ),
              ElevatedButton(
                onPressed: ongoingController.resetTracking,
                child: const Text("Reset"),
              ),
            ],
          );
        }),
      ),
    );
  }
}
