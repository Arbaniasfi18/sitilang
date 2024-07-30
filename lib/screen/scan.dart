import "dart:async";
import "dart:io";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_tflite/flutter_tflite.dart";
import "package:image/image.dart";
// import "package:flutter_screen_capture/flutter_screen_capture.dart";
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";
import "package:screenshot/screenshot.dart";
import "package:sitilang_1_0_0/controllers/data_controller.dart";
import "package:sitilang_1_0_0/controllers/scan_controller.dart";
import "package:sitilang_1_0_0/properties/color.dart";
import "package:sitilang_1_0_0/properties/media_size.dart";
import "package:sitilang_1_0_0/properties/text.dart";
import "package:sitilang_1_0_0/widget/notification.dart";
import "package:flutter_vision/flutter_vision.dart";
import "package:camera/camera.dart";

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late FlutterVision vision;
  late List<CameraDescription> camerass;
  late CameraController cameraController;
  late List<Map<String, dynamic>> yoloResult;
  late Directory? imageDetectionPath;
  late PermissionStatus storePermission;
  ScreenshotController screenshotController = ScreenshotController();
  ScreenshotController screenshotController1 = ScreenshotController();

  CameraImage? cameraImage;

  bool loading = true;
  bool isScan = false;
  bool isTakingScreenshot = false;

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
    await vision.closeYoloModel();
  }

  @override
  void initState() {
    super.initState();
    initFunc();
  }

  initFunc() async {
    camerass = await availableCameras();
    cameraController = await loadCamera(camerass);
    vision = FlutterVision();

    if (mounted) {
      storePermission = await storagePermission(context);
    }

    Future.delayed(const Duration(seconds: 2));

    if (storePermission.isGranted) {
      imageDetectionPath = await getExternalStorageDirectory();

      var temp = DateTime.now().toString().split(" ");

      imageDetectionPath = Directory("${imageDetectionPath?.path}/ImageDetection");
      if (await imageDetectionPath!.exists()) {
        
      }else {
        await imageDetectionPath?.create();
      }

      // imageDetectionPath = Directory("${imageDetectionPath?.path}/2024-06-23");
      imageDetectionPath = Directory("${imageDetectionPath?.path}/${temp[0]}");
      if (await imageDetectionPath!.exists()) {
        
      }else {
        await imageDetectionPath?.create();
      }

      await loadYoLoModel(vision);

      setState(() {
        loading = false;
        yoloResult = [];
      });
    }
  }



  Future startDetection() async {
    setState(() {
      isScan = !isScan;
    });

    if (cameraController.value.isStreamingImages) {
      return;
    }

    await cameraController.startImageStream((image) async {
      if (isScan) {
        cameraImage = image;

        final result = await onYoloFrame(image, vision);

        if(mounted) {
          if (result.isNotEmpty) {
            setState(() {
              yoloResult = result;
            });
          }
        }
      }
    });
  }


  Future stopDetection() async {
    setState(() {
      isScan = false;
      yoloResult = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = Size(mediaWidth(context), mediaHeight(context));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async { 
            if (isScan || isTakingScreenshot)  {
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Mohon matikan deteksi terlebih dahulu"),
                )
              );

            }else {
              
              loadingWidget(context,
              message: "Menyimpan");
              
              await Future.delayed(const Duration(seconds: 10));

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }

            }
          }, 
          icon: const Icon(Icons.arrow_back)
        ),
        title: Text("Scan", style: appBarText),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constrains) {
            return Stack(
              alignment: Alignment.center,
              children: loading 
              ? [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: mediaWidth(context) * 0.9,
                    color: Colors.blue,
                    child: AspectRatio(
                      aspectRatio: 1 / 1.8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                            color: primaryColor,
                            width: 5,
                          )
                        ),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor,),
                        )
                      ),
                    ),
                  ),
                )
              ]
              : [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: mediaWidth(context) * 0.9,
                    decoration: BoxDecoration(
                      border: Border.all(width: 5, color: primaryColor)
                    ),
                    child: Screenshot(
                      controller: screenshotController,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          Size sizeCamera = Size(constraints.maxWidth, constraints.maxHeight);

                          return Stack(
                            children: [
                              Screenshot(
                                controller: screenshotController1,
                                child: CameraPreview(
                                  cameraController,
                                ),
                              ),
                              // ...yoloResult.map((value) {
                              //   var iw = cameraController.value.previewSize!.width;
                              //   var ih = cameraController.value.previewSize!.height;
                              //   var fx = constrains.maxWidth / iw;
                              //   var fy = (iw * fx / (iw / ih)) / ih;
                          
                              //   // Tampilkan Box
                              //   return Positioned(
                              //     left: (value["box"][0] * fx) * 2,
                              //     top: (value["box"][1] * fy) * 2,
                              //     width: (value["box"][2] - value["box"][0]) * fx,
                              //     height: (value["box"][3] - value["box"][1]) * fy,
                              //     child: Container(
                              //       decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2)),
                              //       child: Text(
                              //         "${value['tag']} ${(value['box'][4] * 100).toStringAsFixed(0)}%",
                              //         style: TextStyle(
                              //           background: Paint()..color = Colors.pink,
                              //           color : Colors.pink,
                              //           fontSize: 18
                              //         ),
                              //       ),
                              //     ),
                              //   );
                              // }),
                              ...displayBoxesAroundRecognition(sizeCamera, 
                                yoloResult: yoloResult,
                                cameraImage: cameraImage,
                                screenshotController: screenshotController,
                                screenshotController1: screenshotController1,
                                context: context,
                                imageDetectionPath: imageDetectionPath!,
                                desc: "box",
                                // _controller: cameraController,
                              ),
                              ...displayBoxesAroundRecognition(sizeCamera, 
                                yoloResult: yoloResult,
                                cameraImage: cameraImage,
                                screenshotController: screenshotController,
                                screenshotController1: screenshotController1,
                                context: context,
                                imageDetectionPath: imageDetectionPath!,
                                desc: "name",
                                // _controller: cameraController,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  bottom: 10,
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
            
                        if (isScan) {
                          await stopDetection();
                        }else {
                          await startDetection();
                        }
            
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isScan ? Colors.pink[200]!.withOpacity(0.2) : Colors.pink
                      ),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(isScan ? Icons.remove_red_eye : Icons.remove_red_eye_outlined, color: Colors.white),
                          const Text("Deteksi", style: TextStyle(color: Colors.white),)
                        ],
                      )
                    ),
                  ),
                ),
                // Positioned(
                //   left: 30,
                //   bottom: 10,
                //   child: SizedBox(
                //     width: 150,
                //     child: ElevatedButton(
                //       onPressed: isTakingScreenshot ? null : () async {
            
                //         if(isScan && yoloResult.isNotEmpty) {
                          
                //           loadingWidget(context);

                //           screenshotController.capture().then((image) async {


                //               var temp = DateTime.now().toString().split(" ");
                //               final dateTimeNow = temp.join("_");

                //               File file = File("${imageDetectionPath?.path}/$dateTimeNow.jpg");


                //             if(context.mounted) {
                //               Navigator.pop(context);
                //             }

                //           }).catchError((error) {
                //             print(error);
                //           });

                //         }else {
                          
                //           ScaffoldMessenger.of(context).showSnackBar(
                //             const SnackBar(content: Text("Tidak ada objek")),
                //           );
                //           return;
                //         }

                //       }, 
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.green[800],
                //       ),
                //       child:  const Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                //         children: [
                //           Icon(Icons.save, color: Colors.white),
                //           Text("Simpan", style: TextStyle(color: Colors.white),)
                //         ],
                //       )
                //     ),
                //   ),
                // ),
              ],
            );
          }
        ),
      ),
    );
  }
}