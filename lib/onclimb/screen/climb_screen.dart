import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_stride_sample/onclimb/controller/climb_controller.dart';

class ClimbScreen extends StatelessWidget {
  final ClimbController climbController = Get.put(ClimbController());

  ClimbScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Climb Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Vertical Elevation",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Obx(
                () => Text(
                  "${climbController.totalElevation.value.toStringAsFixed(2)} meters",
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Floor",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Obx(
                () => Text(
                  "${climbController.floorCount.value} floors",
                  style: const TextStyle(fontSize: 24),
                ),
              ),

              const SizedBox(height: 20),
              Obx(() {
                final currentAltitude =
                    climbController.altitudeRoute.isNotEmpty
                        ? climbController.altitudeRoute.last
                        : null;

                if (currentAltitude == null) return const SizedBox.shrink();

                return Column(
                  children: [
                    const Text(
                      "Current Altitude:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${currentAltitude.toStringAsFixed(2)} meters",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 30),
              Obx(() {
                final isTracking = climbController.isTracking.value;
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          isTracking
                              ? null
                              : climbController.startClimbTracking,
                      child: const Text("Start Climb Tracking"),
                    ),
                    ElevatedButton(
                      onPressed:
                          isTracking ? climbController.stopClimbTracking : null,
                      child: const Text("Stop Climb Tracking"),
                    ),
                    ElevatedButton(
                      onPressed: climbController.resetClimbTracking,
                      child: const Text("Reset"),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
