import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_stride_sample/ongoing/controller/ongoing_controller.dart';

class OngoingScreen extends StatelessWidget {
  final OngoingController controller = Get.put(OngoingController());

  final String backgroundImage = 'assets/images/runBackground.png';
  final String characterImage = 'assets/images/ryker.png';

  OngoingScreen({super.key});

  Future<Size> getImageSize(BuildContext context, String imagePath) async {
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
    // ignore: use_build_context_synchronously
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Size(size.width / pixelRatio, size.height / pixelRatio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;

          return FutureBuilder<Size>(
            future: getImageSize(context, backgroundImage),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final imageSize = snapshot.data!;
              final aspectRatio = imageSize.width / imageSize.height;
              final scaledWidth = screenHeight * aspectRatio;
              final isTracking = controller.isTracking.value;

              return Stack(
                children: [
                  Obx(() {
                    final offsetX = controller.offset.value % (scaledWidth * 2);
                    return Stack(
                      children: [
                        Positioned(
                          left: -offsetX,
                          top: 0,
                          width: scaledWidth,
                          height: screenHeight,
                          child: Image.asset(
                            backgroundImage,
                            fit: BoxFit.fill,
                            alignment: Alignment.topLeft,
                          ),
                        ),
                        Positioned(
                          left: scaledWidth - offsetX,
                          top: 0,
                          width: scaledWidth,
                          height: screenHeight,
                          child: Image.asset(
                            backgroundImage,
                            fit: BoxFit.fill,
                            alignment: Alignment.topLeft,
                          ),
                        ),
                      ],
                    );
                  }),
                  Positioned(
                    top: 40,
                    child: Container(
                      width: constraints.maxWidth,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
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
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${controller.totalDistance.value.toStringAsFixed(2)} meters",
                                  style: const TextStyle(fontSize: 24),
                                ),

                                Text(
                                  "${controller.steps.value} Steps",
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 280,
                    child: Image.asset(characterImage, width: 430, height: 430),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 40,
                    right: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed:
                              isTracking
                                  ? null
                                  : () {
                                    controller.startTracking();
                                    controller.start();
                                  },
                          child: const Text("Start"),
                        ),
                        ElevatedButton(
                          onPressed: controller.resetTracking,
                          child: const Text("Reset"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.stopTracking();
                            controller.stop();
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
