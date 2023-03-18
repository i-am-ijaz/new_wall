import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/providers/wallapers_provider.dart';
import 'package:new_wall/ui/shared/custom_app_bar.dart';
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const CustomSliverAppBar(title: 'Trending'),
          SliverToBoxAdapter(
            child: _isWallsListEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: const [
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        GridView.builder(
                          itemCount: wallpapers.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 5 / 7,
                          ),
                          itemBuilder: (context, index) {
                            final wallpaper = wallpapers[index];
                            final isFav =
                                ref.watch(favProvider).isFav(wallpapers[index]);

                            return AspectRatio(
                              aspectRatio: index.isOdd ? 1 : 1.5,
                              child: WallpaperWidget(
                                wallpaper: wallpaper,
                                isFav: isFav,
                                wallpaperList: wallpapers,
                                index: index,
                              ),
                            );
                          },
                        ),
                        if (wallpapersProvider.hasNext)
                          const CircularProgressIndicator(),
                      ],
                    ),
                  ),
          )
        ],
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
