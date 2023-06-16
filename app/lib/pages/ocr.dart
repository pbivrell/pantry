import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  /// Default Constructor
  const CameraApp({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.getMaxZoomLevel().then((value) => _maxAvailableZoom = value);
      controller.getMinZoomLevel().then((value) => _minAvailableZoom = value);
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  void takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }
    if (controller.value.isTakingPicture) {
      return;
    }
    try {
      controller.setFlashMode(FlashMode.off);
      var picture = await controller.takePicture();
      Navigator.pop(context, picture);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: const BackButton(color: Colors.black),
      body: Stack(children: [
        (controller.value.isInitialized)
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: CameraPreview(
                      controller,
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return GestureDetector(
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: IconButton(
                                        onPressed: takePicture,
                                        iconSize: 50,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.camera,
                                            color: Colors.white),
                                      )),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Slider(
                                                value: _currentZoomLevel,
                                                min: _minAvailableZoom,
                                                max: _maxAvailableZoom,
                                                activeColor: Colors.white,
                                                inactiveColor: Colors.white30,
                                                onChanged: (value) async {
                                                  setState(() {
                                                    _currentZoomLevel = value;
                                                  });
                                                  await controller
                                                      .setZoomLevel(value);
                                                },
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  _currentZoomLevel
                                                          .toStringAsFixed(1) +
                                                      'x',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                              )),
                          behavior: HitTestBehavior.translucent,
                          onTapDown: (details) =>
                              onViewFinderTap(details, constraints),
                        );
                      }),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
      ]),
    );
  }
}
