import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/ui/widgets/constants.dart';

final favProvider = ChangeNotifierProvider<FavWallpaperProvider>((ref) {
  return FavWallpaperProvider();
});

class FavWallpaperProvider extends ChangeNotifier {
  void addToFav(Wallpaper wallpaper) {
    final list = Hive.box(Constants.favBox).get(Constants.favListKey);

    if (list.contains(wallpaper.id)) return;

    list.add(wallpaper.id);
    Hive.box(Constants.favBox).put(Constants.favListKey, list);
    notifyListeners();
  }

  void removeFromFav(Wallpaper wallpaper) {
    var list = Hive.box(Constants.favBox).get(Constants.favListKey);

    if (!list.contains(wallpaper.id)) return;

    list.remove(wallpaper.id);
    Hive.box(Constants.favBox).put(Constants.favListKey, list);

    notifyListeners();
  }

  bool isFav(Wallpaper wallpaper) {
    return Hive.box(Constants.favBox)
        .get(Constants.favListKey)
        .contains(wallpaper.id);
  }
}
