import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/ui/screens/view_wallpaper/view_wallaper.dart';
import 'package:new_wall/ui/theme/colors.dart';

class WallpaperWidget extends ConsumerWidget {
  const WallpaperWidget({
    Key? key,
    required this.wallpaper,
    required this.isFav,
    required this.wallpaperList,
    required this.index,
  }) : super(key: key);

  final Wallpaper wallpaper;
  final bool isFav;
  final List<Wallpaper> wallpaperList;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        child: Hero(
          tag: wallpaper.url,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Card(
                margin: EdgeInsets.zero,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(wallpaper.url),
                      fit: BoxFit.cover,
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                type: MaterialType.circle,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    if (isFav) {
                      ref.read(favProvider.notifier).removeFromFav(wallpaper);
                    } else {
                      ref.read(favProvider.notifier).addToFav(wallpaper);
                    }
                  },
                  icon: isFav
                      ? const Icon(
                          Icons.favorite,
                          color: primary,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          color: primary,
                        ),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewWallpaper(
                wallpapers: wallpaperList,
                initialPage: index,
              ),
            ),
          );
        },
      ),
    );
  }
}
