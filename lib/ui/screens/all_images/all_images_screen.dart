import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/ui/widgets/wallpaper_widget.dart';

class AllImagesScreen extends ConsumerWidget {
  const AllImagesScreen({
    Key? key,
    required this.wallpaperList,
  }) : super(key: key);
  final List<Wallpaper> wallpaperList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.green.shade100,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Trending',
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
            child: GridView.builder(
              itemCount: wallpaperList.length,
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 5 / 8,
              ),
              itemBuilder: (context, index) {
                var wallpaper = wallpaperList[index];
                final isFav =
                    ref.watch(favProvider).isFav(wallpaperList[index]);

                return WallpaperWidget(
                  wallpaper: wallpaper,
                  isFav: isFav,
                  wallpaperList: wallpaperList,
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
