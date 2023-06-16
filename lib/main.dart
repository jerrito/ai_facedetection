import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:online_face_detection/defaultButton.dart';
import 'package:online_face_detection/pose_Detector.dart';

import 'cameraPage.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: "Face mood with AI"),
      initialRoute: "home",
      routes: {
        "home": (context) => const MyHomePage(title: "Face mood with AI"),
        "camera": (context) => const CameraPage(),
        // "result": (context) =>  ResultPage(check: true, picture: ,),
      }));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          //color:Colors.black12,
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset("./assets/images/Photo Sharing-amico.png",
                    width: double.infinity, height: 350),
              ),
              SizedBox(height: 100),
              const Center(
                  child: Text(
                      "The camera automatically capture your face mood using AI.",
                      style: TextStyle(fontSize: 18, color: Colors.black))),
              // const  Center(child: Text("Dear you have three attempts to show you are happy",
              //       style:TextStyle(fontSize:18,color:Colors.black))),
              const SizedBox(height: 50),
              DefaultButton(
                  onPressed: () async {
                    await availableCameras().then(
                      (value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CameraPage(cameras: value))),
                    );
                  },
                  backgroundColor: Colors.amberAccent,
                  child: const Text("Let's go")),
              DefaultButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PoseDetectorView()));
                  },
                  backgroundColor: Colors.pinkAccent,
                  child: const Text("Test Pose")),
            ],
          ),
        ),
      ),
    );
  }
}
