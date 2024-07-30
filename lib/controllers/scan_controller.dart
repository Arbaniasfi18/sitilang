import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:screenshot/screenshot.dart';

Future<CameraController> loadCamera(List<CameraDescription> camerass) async {
  CameraController cameraController;
  cameraController = CameraController(camerass[0], ResolutionPreset.high);
    await cameraController.initialize();
  return cameraController;
}

Future loadYoLoModel(FlutterVision vision) async {

  await vision.loadYoloModel(
    modelPath: "assets/detection.tflite", 
    labels: "assets/labels.txt", 
    modelVersion: "yolov8",
    quantization: true,
    numThreads: 3,
    useGpu: false,
  );
}

Future<List<Map<String, dynamic>>> onYoloFrame(CameraImage image, FlutterVision vision) async {

  final result = await vision.yoloOnFrame(
    bytesList: image.planes.map((planes) => planes.bytes).toList(), 
    imageHeight: image.height, 
    imageWidth: image.width,
    iouThreshold: 0.3,  
    confThreshold: 0.5,
    classThreshold: 0.5,
  );

  return result;
}

Future screenshotFunc(ScreenshotController screenshotController, ScreenshotController screenshotController1, Directory imageDetectionPath) async {

  String fileName = "";

  screenshotController1.capture().then((image) async {

    var temp = DateTime.now().toString().split(" ");
    final dateTimeNow = temp.join("_");

    File fileParent = File("${imageDetectionPath.path}/$dateTimeNow.jpg");

    TextRecognizer textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin
    );

    await fileParent.writeAsBytes(image as List<int>);

    InputImage inputImage = InputImage.fromFilePath(fileParent.path);

    RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    bool isPlat = false;
    String platName = "";

    for (TextBlock block in recognizedText.blocks) {
      print(block.text);
      if ((block.text.length >= 6 && block.text.length <= 13) && RegExp(r'^[A-Z0-9 ]+$').hasMatch(block.text)) {
        isPlat = true;
        platName = block.text;
        print("Recognized text get : $platName");
      }
    }


    await fileParent.delete();

    if (isPlat) {
      fileName = "${imageDetectionPath.path}/${dateTimeNow}_$platName.jpg";

    }else {
      fileName = "${imageDetectionPath.path}/${dateTimeNow}_undefined.jpg";

    }

  });
 

  screenshotController.capture().then((image) async {

    File file = File(fileName);

    await file.writeAsBytes(image as List<int>);

    print("File Saved");

  }).catchError((error) {
    print(error);
  });

}


List<Widget> displayBoxesAroundRecognition(Size screen, {
  required List<Map<String, dynamic>> yoloResult, 
  CameraImage? cameraImage,
  required ScreenshotController screenshotController,
  required ScreenshotController screenshotController1,
  required BuildContext context,
  required Directory imageDetectionPath,
  required String desc,

  }) {

  double factorX = 0;
  double factorY = 0;

  if (cameraImage != null) {
    factorX = (screen.width * 0.9)/ (cameraImage.height);
    factorY = (screen.height * 0.87) / (cameraImage.width);

  }

  if (yoloResult.isEmpty) {
    return [];
  }

  bool isPlatDetected = false;
  bool isNoHelmDetected = false;

  yoloResult.forEach((value) {

    if (value['tag'] == "Plat") {
      isPlatDetected = true;
    }

    if (value['tag'] == "No helm") {
      isNoHelmDetected = true;
    }

  });

  if (isPlatDetected && isNoHelmDetected) {
    
    screenshotFunc(screenshotController, screenshotController1, imageDetectionPath);

  }

  return yoloResult.map((value) {

    double objectX = value["box"][0] * factorX;
    double objectY = value["box"][1] * factorY;
    double objectWidth = (value["box"][2] - value["box"][0]) * factorX;
    double objectHeight = (value["box"][3] - value["box"][1]) * factorY;

    // print("==================$desc=========================");
    // print(screen.width);
    // print(yoloResult);
    // print(objectX);
    // print(objectY);
    // print(objectWidth);
    // print(objectHeight);
    // print("====================================================");

    if (desc == "name") {

      return Positioned(
        left: objectX + 20,
        top: objectY - 23,
        child: Text(
          "${value['tag']} ${(value['box'][4] * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            background: Paint()..color = value['tag'] == "Plat" ? Colors.pink : Colors.yellow,
            color : const Color.fromARGB(255, 115, 0, 255),
            fontSize: 16
          ),
      ));

    }else {
      
      return Positioned(
        left: objectX + 20,
        top: objectY,
        width: objectWidth + 10 ,
        height: objectHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(width: 2, color: value['tag'] == "Plat" ? Colors.pink : Colors.yellow,),
          ),
        )
      );

    }


  }).toList();

}