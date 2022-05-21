import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_wall/ui/widgets/wallpaper_widget.dart';
import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/services/firestore_service.dart';

class CategoryWallpapers extends StatelessWidget {
  const CategoryWallpapers({Key? key, required this.category})
      : super(key: key);
  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category[0].toUpperCase() + category.substring(1),
        ),
      ),
      body: StreamBuilder<List<Wallpaper>>(
        stream: FirestoreService.wallpapers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final categoryWallpapers = snapshot.data!
              .where(
                (element) => element.tag == category,
              )
              .toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 5 / 7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categoryWallpapers.length,
            itemBuilder: (context, index) {
              final wall = categoryWallpapers.elementAt(index);
              return Consumer(
                builder: (context, WidgetRef ref, _) {
                  final isFav = ref
                      .watch(
                        favProvider,
                      )
                      .isFav(
                        categoryWallpapers[index],
                      );

                  return WallpaperWidget(
                    wallpaper: wall,
                    isFav: isFav,
                    wallpaperList: categoryWallpapers,
                    index: index,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
