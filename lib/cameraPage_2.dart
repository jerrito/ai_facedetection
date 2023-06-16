import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:online_face_detection/main.dart';

class CameraPage2 extends StatefulWidget {
  final CustomPaint? customPaint;
  final CameraLensDirection? initialDirection;
  final String? text;
  final Function(InputImage inputImage) onImage;
  const CameraPage2(
      {Key? key,
      this.customPaint,
      this.text,
      required this.onImage,
      this.initialDirection})
      : super(key: key);
  // WidgetsFlutterBinding.ensureInitialized();
  @override
  State<CameraPage2> createState() => _CameraPage2State();
}

class _CameraPage2State extends State<CameraPage2> {
  final GlobalKey<ScaffoldMessengerState> scaffold =
      GlobalKey<ScaffoldMessengerState>();
  bool confirm_3 = false;
  bool attempt = false;

  CameraController? _cameraController;
  //cameras = await availableCameras() ;
  ui.Image? image;
  List<Rect> rects = [];
  bool isSmiling = false;
  int index = 0;
  int index_2 = 2;
  int _cameraIndex = -1;
  bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();

    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    if (_cameraIndex != -1) {
      initCamera();
    } else {
      // _mode = ScreenMode.gallery;
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(key: scaffold, body: body()),
    );
  }

  Widget body() {
    if (_cameraController?.value.isInitialized == false) {
      return Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _cameraController!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: _changingCameraLens
                  ? Center(
                      child: const Text('Changing camera lens'),
                    )
                  : CameraPreview(_cameraController!),
            ),
          ),
          if (widget.customPaint != null) widget.customPaint!,
        ],
      ),
    );
    return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: CameraPreview(
          _cameraController!,
        ));
  }

  Future initCamera() async {
    //WidgetsFlutterBinding.ensureInitialized();
// create a CameraController
    final camera = cameras[_cameraIndex];
    _cameraController = CameraController(camera, ResolutionPreset.ultraHigh,
        imageFormatGroup: ImageFormatGroup
            .jpeg); // Next, initialize the controller. This returns a Future.
    try {
      await _cameraController?.initialize().then((_) {
        if (!mounted) return;
        _cameraController?.startImageStream(_processCameraImage);
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera error $e");
    }
  }

  Future _stopLiveFeed() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    // _cameraController = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[1];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}
