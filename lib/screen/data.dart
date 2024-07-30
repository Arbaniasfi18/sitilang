import 'dart:io';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sitilang_1_0_0/controllers/data_controller.dart';
import 'package:sitilang_1_0_0/properties/color.dart';
import 'package:sitilang_1_0_0/properties/media_size.dart';
import 'package:sitilang_1_0_0/properties/spacing.dart';
import 'package:sitilang_1_0_0/properties/text.dart';
import 'package:sitilang_1_0_0/widget/data_list.dart';
import 'package:sitilang_1_0_0/widget/data_list_skeleton.dart';
import 'package:sitilang_1_0_0/widget/notification.dart';

class DataPage extends StatefulWidget {
  final String date;
  const DataPage(this.date, {super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Directory? storagePath;
  late Directory imageDetectionPath;
  late List<FileSystemEntity> listImageFile;
  late List<FileSystemEntity> listDirectory;
  late List<String> listFileName;
  List<String> listPlatName = [];
  late String date;
  int tempPlat = 0;
  

  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    date = widget.date;

    initFunc();
  }

  initFunc() async {

    var permission = await storagePermission(context);

    if (permission.isGranted) {
      imageDetectionPath = await accessSubFolder();

      if (imageDetectionPath.path != "") {


        listDirectory = getAllDirOrFiles(imageDetectionPath);
        listFileName = [];
        listImageFile = [];
        
        if (listDirectory.isNotEmpty) {

          if (date.isEmpty) {
            listImageFile = getAllDirOrFiles(listDirectory[0] as Directory);
          }else {
            
            listDirectory.forEach((value) {
              if (basename(value.path) == date) {
                listImageFile = getAllDirOrFiles(value as Directory);
                return;
              }
            });

          }

          List stat = [];

          stat = await Future.wait([
            for (var path in listImageFile) FileStat.stat(path.path)
          ]);

          var mtimes = <dynamic, DateTime>{
            for (var i = 0; i < listImageFile.length; i += 1)
              listImageFile[i]: stat[i].changed,
          };

          listImageFile.sort((a, b) => mtimes[b]!.compareTo(mtimes[a]!));

          listImageFile.forEach((value) {
            var temp = basename(value.path).split("_");
            if (temp.length > 2) {
              var platname = temp[2].split(".");
              listPlatName.add(platname[0]);
            }
            List name = temp[1].split(":");
            listFileName.add("${name[0]}:${name[1]}");
          });


        }


        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data", style: appBarText),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeightSpacing(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: loading || listDirectory.isEmpty
              ? Text("YYYY-MM-YY", style: other)
              : DropdownButton(
                hint: Text(date.isEmpty ? basename(listDirectory[0].path) : date, style: other),
                onChanged: (value) {
                  if (value != date) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DataPage(value.toString())));
                  }
                },
                items: [
                  for (var i in listDirectory)
                    DropdownMenuItem(value: basename(i.path),child: Text(basename(i.path), style: other))
                ]
              ),
            ),
            HeightSpacing(10),
            Container(
              height: 1,
              width: mediaWidth(context),
              color: Colors.black,
            ),
            Expanded(
              child: loading 
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    DataListSkeleton(context),
                    DataListSkeleton(context),
                    DataListSkeleton(context),
                    DataListSkeleton(context),
                  ]
                ),
              )
              : listImageFile.isNotEmpty 
              ? ListView.builder(
                itemCount: listImageFile.length,
                itemBuilder: (context, index) {
                    if (tempPlat >= 3) {
                      tempPlat = 0;
                    }
                    String platName = "";

                    tempPlat += 1;
                    String namePlatImage = "assets/images/plat_$tempPlat.jpeg";
                    if (tempPlat == 3) {
                      platName = "BB 6972 ML";
                    }else {
                      platName = "BK 2364 AIO";
                    }


                  return DataList(context, 
                  image: listImageFile[index] as File,
                  name: listFileName[index],
                  plat: listPlatName.isNotEmpty ? listPlatName[index] : "BK 123 K",
                  imagePlat: namePlatImage, 
                  );
              })
              : const Center(child: Text("Tidak ada data yang disimpan")),
            ),
          ],
        )
      ),
    );
  }
}