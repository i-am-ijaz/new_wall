import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/providers/wallapers_provider.dart';
import 'package:new_wall/ui/shared/shimmer_widgets/shimmer_wallpaper_widget.dart';
import 'package:new_wall/ui/shared/wallpaper_widget.dart';

class TrendingScreen extends ConsumerStatefulWidget {
  const TrendingScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends ConsumerState<TrendingScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    ref.read(wallapersProvider).fetchNextWalls();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallpapersProvider = ref.watch(wallapersProvider);
    final wallpapers = wallpapersProvider.wallPapers();

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        // slivers: [
        // const CustomSliverAppBar(title: 'Trending'),
        child: _isWallsListEmpty
            ? const ShimmerWallpaperWidget()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    StaggeredGrid.count(
                      crossAxisCount: 4,
                      children: List.generate(
                        wallpapers.length,
                        (index) {
                          final isFav =
                              ref.watch(favProvider).isFav(wallpapers[index]);

                          return StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: index.isEven ? 2.5 : 3,
                            child: WallpaperWidget(
                              wallpaper: wallpapers[index],
                              isFav: isFav,
                              wallpaperList: wallpapers,
                              index: index,
                            ),
                          );
                        },
                      ),
                      axisDirection: AxisDirection.down,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                    if (wallpapersProvider.hasNext)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
      ),
    );
  }

  bool get _isWallsListEmpty {
    return ref.read(wallapersProvider).wallPapers().isEmpty;
  }

  void _scrollListener() {
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final outOfRange = _scrollController.position.outOfRange;

    if (_scrollController.offset >= (maxScrollExtent / 2) && !outOfRange) {
      if (ref.read(wallapersProvider).hasNext) {
        ref.read(wallapersProvider).fetchNextWalls();
      }
    }
  }
}
