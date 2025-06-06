import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_stride_sample/animation/horizontal/controller/horizontal_scroll_controller.dart';

class HorizontalAnimation extends StatelessWidget {
  final HorizontalScrollController controller = Get.put(
    HorizontalScrollController(),
  );

  final String backgroundImage = 'assets/images/runBackground.png';
  final String characterImage = 'assets/images/ryker.png';

  HorizontalAnimation({super.key});

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
