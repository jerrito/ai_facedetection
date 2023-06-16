import 'package:online_face_detection/cameraPage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class ResultPage extends StatefulWidget {
  final bool check;
  final XFile picture;
  const ResultPage({Key? key, required this.check, required this.picture}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  File? fixedFile;

  void imageUpdate()async{
    List<int> imageBytes = await widget.picture.readAsBytes();

    img.Image? originalImage = img.decodeImage(Uint8List.fromList(imageBytes));
    img.Image fixedImage = img.flipHorizontal(originalImage!);

    File file = File(widget.picture.path);
    fixedFile = await file.writeAsBytes(
      img.encodeJpg(fixedImage),
      flush: true,
    );
  }

@override
  void initState() {
 imageUpdate();
  }
// late bool check;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color:Colors.amberAccent,
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child:widget.check?
                  const Text("Oh dear you look happy",style:TextStyle(
                    fontSize: 22,color:Colors.white,
                  )):const Text("Oh dear you don't look happy",style:TextStyle(
                    fontSize: 22,color:Colors.redAccent,
                  ))
              ),
              Center(
                child:widget.check?
          Image.asset("./assets/images/Smiley face-bro.png"):Image.asset("./assets/images/Dizzy face-bro.png")
              ),
              Container(
                margin:const EdgeInsets.only(left:10,right:10,top:10),
                width: double.infinity-20,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder:
                  (context)=> PictureDisplay(pic_path:fixedFile?.path)));
                  },
                    style:ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal:16),
                      shape:const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("See your face")
                ),
              ),
              Container(
                margin:const EdgeInsets.only(left:10,right:10,top:10),
                width: double.infinity-20,
                child: ElevatedButton(onPressed: ()async{
                  await availableCameras().then(
                        (value) => Navigator.push(
                        context, MaterialPageRoute(
                        builder: (_) => CameraPage(cameras: value))
                    ),
                  );

                },style:ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal:16),
                      shape:const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Capture again")
                ),
              ),
              Container(
                margin:const EdgeInsets.only(left:10,right:10,top:10),
                width: double.infinity-20,
                child: ElevatedButton(onPressed: (){
       Navigator.pushReplacementNamed(context, "home");
                },
                    style:ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal:16),
                      shape:const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Go To Home Page")
                ),
              )


            ],
          )


        ),
      ),
    );
  }
}


class PictureDisplay extends StatefulWidget {
  final String? pic_path;

  const PictureDisplay({Key? key, required this.pic_path}) : super(key: key);

  @override
  State<PictureDisplay> createState() => _PictureDisplayState();
}

class _PictureDisplayState extends State<PictureDisplay> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body:Container(
          margin: EdgeInsets.only(left:10,right: 10,top:40),
          child: Column(
            children: [
              Container(
                width:double.infinity,height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit:BoxFit.cover,
                    image:  FileImage(
                    File(widget.pic_path!))),
                  border: Border.all(width:2,color:Colors.amberAccent,style: BorderStyle.solid)
                ),),
              const SizedBox(height:30),
              Container(
                width: double.infinity,margin: const EdgeInsets.only(top:10),
                child: ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                },
                    style:ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal:16),
                      shape:const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.white,
                    ),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                       children:const[
                         Icon(Icons.arrow_back,color: Colors.black),
                         SizedBox(width:10),
                         Text( "Return ", style: TextStyle(color: Colors.black)),


               ] ),
              ),),
              // Container(
              //   width: double.infinity,margin: EdgeInsets.only(top:10),
              //   child: ElevatedButton(onPressed: ()async{
              //     await availableCameras().then(
              //           (value) => Navigator.pushReplacement(
              //           context, MaterialPageRoute(
              //           builder: (_) => CameraPage(cameras: value))
              //       ),
              //     );
              //   },
              //       style:ElevatedButton.styleFrom(
              //         alignment: Alignment.center,
              //         padding: const EdgeInsets.symmetric(vertical: 16,horizontal:16),
              //         shape:const RoundedRectangleBorder(
              //             borderRadius: BorderRadius.all(Radius.circular(10))
              //         ),
              //         backgroundColor: Colors.blueAccent,
              //         foregroundColor: Colors.white,
              //       ),
              //       child: const Text("Capture again", style: TextStyle(color: Colors.white))
              //   ),
              // ),
              // Container(
              //   width: double.infinity,margin: EdgeInsets.only(top:10),
              //   child: ElevatedButton(onPressed: (){
              //     Navigator.pushReplacementNamed(context, "home");
              //   },
              //       style:ElevatedButton.styleFrom(
              //         alignment: Alignment.center,
              //         padding: const EdgeInsets.symmetric(vertical: 16,horizontal:16),
              //         shape:const RoundedRectangleBorder(
              //             borderRadius: BorderRadius.all(Radius.circular(10))
              //         ),
              //         backgroundColor: Colors.redAccent,
              //         foregroundColor: Colors.white,
              //       ),
              //       child: const Text("Go To Home Page", style: TextStyle(color: Colors.white))
              //   ),
              // )

            ],
          ),
        )
      ),
    );
  }
}
