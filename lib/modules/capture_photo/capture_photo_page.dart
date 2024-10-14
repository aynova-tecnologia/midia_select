import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CapturePhotoPage extends StatefulWidget {
  final List<Orientation> allowedPhotoOrientations;
  const CapturePhotoPage({
    Key? key,
    this.allowedPhotoOrientations = const [
      Orientation.landscape,
      Orientation.portrait
    ],
  }) : super(key: key);

  @override
  State<CapturePhotoPage> createState() => _CapturePhotoPageState();
}

class _CapturePhotoPageState extends State<CapturePhotoPage> {
  late CameraDescription camera;
  late CameraController controller;
  bool _isInited = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    log('Capture Photo Page');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cameras = await availableCameras();
      print(cameras);
      // setState(() {});
      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      controller.initialize().then(
            (value) => {
              setState(() {
                _isInited = true;
              })
            },
          );
      controller.setFlashMode(FlashMode.auto);
    });
  }

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    print('Orientação do dispositivo : $currentOrientation');
    final verifyOrientation =
        widget.allowedPhotoOrientations.contains(currentOrientation);
    return Scaffold(
      backgroundColor: Colors.black,
      body: _imagePath == null
          ? Stack(
              children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: _isInited
                            ? AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: CameraPreview(controller),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
                if (!verifyOrientation)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red
                            .withOpacity(0.8), // Cor de fundo com opacidade
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tire a foto na orientação de tela correta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            )
          : SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Image.file(
                  File(
                    _imagePath!,
                  ),
                ),
              ),
            ),
      floatingActionButton: _imagePath == null
          ? verifyOrientation
              ? FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: 'camera',
                  child: const Icon(
                    Icons.camera,
                  ),
                  onPressed: () async {
                    await controller.takePicture().then(
                          (res) => {
                            setState(() {
                              _imagePath = res.path;
                            })
                          },
                        );
                  },
                )
              : const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  heroTag: 'clear',
                  backgroundColor: Colors.black,
                  child: const Icon(
                    Icons.close,
                  ),
                  onPressed: () async {
                    setState(() {
                      _imagePath = null;
                    });
                  },
                ),
                FloatingActionButton(
                  heroTag: 'done',
                  child: const Icon(
                    Icons.done,
                  ),
                  onPressed: () async {
                    Navigator.pop(
                      context,
                      _imagePath,
                    );
                  },
                )
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
