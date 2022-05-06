import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> setWallpaperBottomSheet(BuildContext context, String url) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 140.0),
              child: Divider(
                thickness: 5,
                color: Colors.black,
              ),
            ),
            const Text(
              'Set as',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  child: const Text('Home Screen'),
                  onPressed: () async {
                    int location = WallpaperManager.HOME_SCREEN;
                    var file = await DefaultCacheManager().getSingleFile(url);

                    await WallpaperManager.setWallpaperFromFile(
                      file.path,
                      location,
                    );

                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: const Text('Lock Screen'),
                  onPressed: () async {
                    int location = WallpaperManager.LOCK_SCREEN;
                    var file = await DefaultCacheManager().getSingleFile(url);

                    await WallpaperManager.setWallpaperFromFile(
                      file.path,
                      location,
                    );

                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: const Text('Both'),
                  onPressed: () async {
                    int location = WallpaperManager.HOME_SCREEN;
                    var file = await DefaultCacheManager().getSingleFile(url);

                    await WallpaperManager.setWallpaperFromFile(
                      file.path,
                      location,
                    );

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> openFile({
  required File file,
}) async {
  await OpenFile.open(file.path);
}

Future<File?> downloadWallpaper(String url) async {
  var status = await Permission.storage.request();

  if (status.isGranted) {
    try {
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: 0,
        ),
      );

      File file = await saveImageToGallery(url, response);

      final ref = file.openSync(mode: FileMode.write);

      ref.writeFromSync(response.data);
      await ref.close();

      return file;
    } catch (e) {
      print(e);
    }
  }
  return null;
}

Future<File> saveImageToGallery(String url, Response<dynamic> response) async {
  var dir = await getExternalStorageDirectory();

  String fileName = getFileName(url);

  String newPath = "";
  List<String> folders = dir!.path.split('/');

  for (int i = 0; i < folders.length - 1; i++) {
    String folder = folders[i];

    if (folder != 'Android') {
      newPath += folder + '/';
    } else {
      break;
    }
  }

  newPath = newPath + '/New Wall';
  dir = Directory(newPath);
  newPath = dir.path + '/' + fileName;

  File file = File(newPath);

  await file.writeAsBytes(response.data);
  try {
    final isSaved = await GallerySaver.saveImage(
      file.path,
      albumName: 'New Wall',
    );
    log(isSaved.toString());
  } catch (e) {
    log(e.toString());
  }
  return file;
}

String getFileName(String url) {
  RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
  var matches = regExp.allMatches(url);
  var match = matches.elementAt(0);
  return Uri.decodeFull(match.group(2)!);
}

// ignore: unused_element
Future<void> _showOpenSettingsAlert(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Need access to storage.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Open settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          )
        ],
      );
    },
  );
}
