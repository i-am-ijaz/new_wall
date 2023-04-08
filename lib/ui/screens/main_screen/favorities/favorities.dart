import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/ui/shared/wallpaper_widget.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';

class FavoritiesScreen extends ConsumerWidget {
  const FavoritiesScreen({
    Key? key,
    required this.wallpapersList,
  }) : super(key: key);
  final List<Wallpaper> wallpapersList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Wallpaper> favWalls = [];

    final isFavProvider = ref.watch(favProvider);

    for (final wall in wallpapersList) {
      if (isFavProvider.isFav(wall)) {
        favWalls.add(wall);
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: favWalls.isEmpty
            ? SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: const Center(
                    child: Text('You have no favorites yet'),
                  ),
                ),
              )
            : GridView.builder(
                itemCount: favWalls.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 5 / 7,
                ),
                itemBuilder: (context, index) {
                  var favWall = favWalls[index];

                  return WallpaperWidget(
                    wallpaper: favWall,
                    isFav: isFavProvider.isFav(favWall),
                    wallpaperList: favWalls,
                    index: index,
                  );
                },
              ),
      ),
    );
  }
}
