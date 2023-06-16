import 'package:online_face_detection/snackbars.dart';
import 'package:camera/camera.dart' ;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui ;
import 'dart:io';
import 'result.dart';





class CameraPage extends StatefulWidget {
  final List<CameraDescription> ? cameras;
  const CameraPage({Key? key, this.cameras}) : super(key: key);
  // WidgetsFlutterBinding.ensureInitialized();
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
 final GlobalKey<ScaffoldMessengerState> scaffold=GlobalKey<ScaffoldMessengerState>();
  bool confirm_3=false;
  bool attempt=false;


  late CameraController _cameraController;
  //cameras = await availableCameras() ;
  ui.Image? image;
  List<Rect> rects = [];
  bool isSmiling = false;
  int index=0;
  int index_2=2;

  Container capture_time() {
    return Container(
        child: TweenAnimationBuilder(
            tween: Tween(begin: 10.0, end: 0), duration: Duration(seconds: 10),
            builder: (BuildContext context, value, Widget? child)=>
                Text("Wait for 00:${(value).toInt()}s",
                  style: TextStyle(color: Colors.amberAccent, fontSize: 25),)
        )

    ); }
  @override
  void initState(){
    super.initState();
    initCamera(widget.cameras![1]);

  }
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: SafeArea(
        child: Scaffold(
          key:scaffold,
            body: _cameraController.value.isInitialized
                ?SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,child:
            CameraPreview(_cameraController,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  capture_time(),
                  Visibility(
                    visible:attempt,
                    child: Text("Attempt left: $index_2",
                        style: TextStyle(color: Colors.amberAccent, fontSize: 16)),
                  ),
                  //Center(child: Text("Position your face infront of the camera",style: TextStyle(color: Colors.white, fontSize: 16)),),
                  SizedBox(height:10),



            ]))) : const Center(child:
            CircularProgressIndicator())
                
    ),
      ));


  }
  Future initCamera(CameraDescription cameraDescription) async {
    //WidgetsFlutterBinding.ensureInitialized();
// create a CameraController


    _cameraController = CameraController(
        widget.cameras![1],
        ResolutionPreset.ultraHigh, imageFormatGroup: ImageFormatGroup.jpeg);// Next, initialize the controller. This returns a Future.
    try {
      await _cameraController.initialize().then((_) {

        if (!mounted) return;
        setState(() {
          Future.delayed(Duration(seconds: 10),() async {

            try {
              //_cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
              final camera_image = await _cameraController.takePicture();

              // await controller.startImageStream((imagese) =>

              XFile imagePickedFile = await camera_image;

              final inputImage = InputImage.fromFilePath(imagePickedFile.path);


              //Where the face detector algorithm begins
              final FaceDetector faceDetector = FaceDetector(
                  options: FaceDetectorOptions(enableContours: true, enableClassification: true,));


              final List<Face> faces = await faceDetector.processImage(inputImage);

              rects.clear();
              if(faces.isNotEmpty) {
                for (Face face in faces) {
                  isSmiling = face.smilingProbability! >= 0.6; //checking if smiling
                  rects.add(face.boundingBox);
                }
                var bytesFromImageFile = await imagePickedFile.readAsBytes();
                decodeImageFromList(bytesFromImageFile).then((img) {
                  setState(() {
                    image = img;
                    if (isSmiling == true) {
                     // print("Smiling");
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder:
                              (context) =>
                              ResultPage(check: true, picture: camera_image)));
                    }
                    else {
                      print("Face is not empty");
                      attempt=true;
                      initCamera(widget.cameras![1]);
                      print(index);
                      AISnackBar(context).displaySnackBar(
                        message: "Position your face infront of the camera.\nAnd smile for the camera",
                        backgroundColor: Colors.amberAccent,
                      );

                      if (index == 2) {
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder:
                            (context) =>
                            ResultPage(check: false, picture: camera_image,)));
                      }
                      index++;
                      index_2--;
                      print("Not Smiling");
                      // Navigator.pop(context);
                    }
                  });});}
              else{
                print("Face is empty");


                setState((){
                  attempt=false;
                  initCamera(widget.cameras![1]);
                  AISnackBar(context).displaySnackBar(
                    message: "No face detected\nPosition your face infront of the camera",
                    backgroundColor: Colors.amberAccent,
                  );

                print(index);

                // if (index == 2) {
                //   Navigator.pushReplacement(
                //       context, MaterialPageRoute(builder:
                //       (context) =>
                //       ResultPage(check: false, picture: camera_image,)));
                // }
                // index++;
                // index_2--;
                });

              }
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          });
        });

      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(217, 217, 217, 1),
            content: Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.circular(10)),
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Are you sure you want to exit camera?"),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _cameraController.dispose().then((_) {
                              _cameraController.pausePreview();
                              Navigator.pop(context);
                            });
                            Navigator.pop(context);
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => ProfileSettings(
                            //         profileUpdate: ProfileUpdate(
                            //           //imagePath:returnURL,
                            //             check: "see", imagePath: '${userProvider?.appUser?.image}'
                            //         )),
                            //   ),);
                          },
                          child: Text("Yes"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                              foregroundColor: Colors.white),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("No", style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              // shape: const OutlinedBorder(
                              //   side: BorderSide(color: Colors.blue,width: 2,style: BorderStyle.solid)
                              // )
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
