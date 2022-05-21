import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_wall/ui/widgets/wallpaper_widget.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';

class FavoritiesScreen extends ConsumerWidget {
  const FavoritiesScreen({
    Key? key,
    required this.wallpaperList,
  }) : super(key: key);
  final List<Wallpaper> wallpaperList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Wallpaper> favWalls = [];

    final isFavProvider = ref.watch(favProvider);

    for (var wall in wallpaperList) {
      if (isFavProvider.isFav(wall)) {
        favWalls.add(wall);
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.green.shade100,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Favorities',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            pinned: true,
            floating: true,
            expandedHeight: 180,
          ),
          SliverToBoxAdapter(
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
          )
        ],
      ),
    );
  }
}
