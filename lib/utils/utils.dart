import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

import 'package:new_wall/ui/screens/view_wallpaper/view_wallaper.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 140.0),
              child: Divider(
                thickness: 2,
                color: Colors.black,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Apply',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  child: const Text('Home Screen Wallpaper'),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (_) => const ProgressDialogContent(),
                    );

                    int loc = WallpaperManager.HOME_SCREEN;
                    final file = await DefaultCacheManager().getSingleFile(url);
                    final path = file.path;

                    final isSet = await WallpaperManager.setWallpaperFromFile(
                      path,
                      loc,
                    );

                    if (isSet) {
                      showMessage("Wallpaper has been set");
                    }

                    Navigator.of(context, rootNavigator: true).pop();

                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: const Text('Lock Screen Wallpaper'),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (_) => const ProgressDialogContent(),
                    );

                    int loc = WallpaperManager.LOCK_SCREEN;
                    final file = await DefaultCacheManager().getSingleFile(url);
                    final path = file.path;

                    final isSet = await WallpaperManager.setWallpaperFromFile(
                      path,
                      loc,
                    );

                    if (isSet) {
                      showMessage("Wallpaper has been set");
                    }

                    Navigator.of(context, rootNavigator: true).pop();

                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: const Text('Both'),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (_) => const ProgressDialogContent(),
                    );

                    int loc = WallpaperManager.BOTH_SCREEN;
                    final file = await DefaultCacheManager().getSingleFile(url);
                    final path = file.path;

                    final isSet = await WallpaperManager.setWallpaperFromFile(
                      path,
                      loc,
                    );

                    if (isSet) {
                      showMessage("Wallpaper has been set");
                    }

                    Navigator.of(context, rootNavigator: true).pop();

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

void showMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
  );
}

Future<void> openFile({
  required String path,
}) async {
  await OpenFile.open(path);
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
