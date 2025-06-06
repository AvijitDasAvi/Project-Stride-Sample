import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_stride_sample/onclimb/controller/climb_controller.dart';

class ClimbScreen extends StatelessWidget {
  final String backgroundImage = 'assets/images/climbBackground.png';
  final String characterImage = 'assets/images/rykerElevator.png';
  final ClimbController climbController = Get.put(ClimbController());

  ClimbScreen({super.key});

  Future<Size> getImageSize(String imagePath, double devicePixelRatio) async {
    final imageProvider = AssetImage(imagePath);
    final completer = Completer<Size>();
    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool synchronousCall) {
            completer.complete(
              Size(info.image.width.toDouble(), info.image.height.toDouble()),
            );
          }),
        );
    final size = await completer.future;
    return Size(size.width / devicePixelRatio, size.height / devicePixelRatio);
  }

  static const _whiteTextStyle = TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          return FutureBuilder<Size>(
            future: getImageSize(backgroundImage, devicePixelRatio),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading background image'),
                );
              }
              final imageSize = snapshot.data!;
              final aspectRatio = imageSize.width / imageSize.height;
              final scaledHeight = screenWidth / aspectRatio;

              return Stack(
                children: [
                  Obx(() {
                    final offsetY =
                        climbController.offset.value % (scaledHeight * 2);
                    return Stack(
                      children: [
                        Positioned(
                          top: offsetY,
                          left: 0,
                          width: screenWidth,
                          height: scaledHeight,
                          child: Image.asset(
                            backgroundImage,
                            fit: BoxFit.fill,
                            alignment: Alignment.topLeft,
                          ),
                        ),
                        Positioned(
                          top: offsetY - scaledHeight,
                          left: 0,
                          width: screenWidth,
                          height: scaledHeight,
                          child: Image.asset(
                            backgroundImage,
                            fit: BoxFit.fill,
                            alignment: Alignment.topLeft,
                          ),
                        ),
                      ],
                    );
                  }),
                  Center(
                    child: Image.asset(characterImage, height: 600, width: 600),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 40,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Vertical Elevation",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Obx(
                            () => Text(
                              "${climbController.totalElevation.value.toStringAsFixed(2)} meters",
                              style: _whiteTextStyle.copyWith(fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Floor",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Obx(
                            () => Text(
                              "${climbController.floorCount.value} floors",
                              style: _whiteTextStyle.copyWith(fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            final currentAltitude =
                                climbController.altitudeRoute.isNotEmpty
                                    ? climbController.altitudeRoute.last
                                    : null;

                            if (currentAltitude == null) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                const Text(
                                  "Current Altitude:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${currentAltitude.toStringAsFixed(2)} meters",
                                  style: _whiteTextStyle.copyWith(fontSize: 18),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 40,
                    left: 40,
                    right: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            climbController.startClimbTracking();
                          },
                          child: const Text("Start"),
                        ),
                        ElevatedButton(
                          onPressed: climbController.resetClimbTracking,
                          child: const Text("Reset"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            climbController.stopClimbTracking();
                          },
                          child: const Text("Stop"),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
