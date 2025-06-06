import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_stride_sample/animation/vertical/controller/vertical_scroll_controller.dart';

class VerticalAnimation extends StatelessWidget {
  final VerticalScrollController controller = Get.put(
    VerticalScrollController(),
  );

  final String backgroundImage = 'assets/images/climbBackground.png';
  final String characterImage = 'assets/images/rykerElevator.png';

  VerticalAnimation({super.key});

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
          final screenWidth = constraints.maxWidth;

          return FutureBuilder<Size>(
            future: getImageSize(context, backgroundImage),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final imageSize = snapshot.data!;
              final aspectRatio = imageSize.width / imageSize.height;
              final scaledHeight = screenWidth / aspectRatio;

              return Stack(
                children: [
                  Obx(() {
                    final offsetY =
                        controller.offset.value % (scaledHeight * 2);
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

                  Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Image.asset(characterImage, width: 650, height: 650),
                  ),

                  Positioned(
                    bottom: 40,
                    left: 40,
                    right: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: controller.start,
                          child: const Text("Start"),
                        ),
                        ElevatedButton(
                          onPressed: controller.stop,
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
