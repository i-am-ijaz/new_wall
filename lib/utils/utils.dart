import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:open_file/open_file.dart';
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
