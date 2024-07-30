import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sitilang_1_0_0/widget/notification.dart';

  List<FileSystemEntity> getAllDirOrFiles(Directory imageDetectionPath) {
    List<FileSystemEntity> listImageFile;
    listImageFile = imageDetectionPath.listSync();
    return listImageFile;
  }

  Future<Directory> accessSubFolder() async {
    Directory? storagePath;
    Directory imageDetectionPath = Directory("");
    storagePath = await getExternalStorageDirectory();
    if (await storagePath!.exists()) {
      imageDetectionPath = Directory("${storagePath.path}/ImageDetection");

      if (await imageDetectionPath.exists()) {
        print("Exist");
      }else {
        await imageDetectionPath.create();
        print("not Exist");
      }

      return imageDetectionPath;

    }

      return imageDetectionPath;

  }

  Future<PermissionStatus> storagePermission(context) async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    PermissionStatus status = PermissionStatus.denied;

    if (androidInfo.version.sdkInt >= 33) {
      PermissionStatus videoStat = await Permission.videos.status;
      PermissionStatus imageStat = await Permission.photos.status;

      if (!videoStat.isGranted) {
        await Permission.videos.request();
      }
      if (!imageStat.isGranted) {
        await Permission.photos.request();
      }
      if (!videoStat.isPermanentlyDenied || !imageStat.isPermanentlyDenied) {
        warnNotif(context, content: const Text("Mohon izinkan penyimpanan internal agar memudahkan penggunaan aplikasi"));
      }
      if (!videoStat.isGranted || !imageStat.isGranted) {
        await storagePermission(context);
      }else {
        status = PermissionStatus.granted;
      }
    
      return status;

    }else {
      status = await Permission.storage.status;

      if (!status.isGranted) {
        await Permission.storage.request();

        if (status.isPermanentlyDenied) {
          warnNotif(context, content: const Text("Mohon izinkan penyimpanan internal agar memudahkan penggunaan aplikasi"));
        }else {
          await storagePermission(context);
        }
      }

      return status;

    }
  }
