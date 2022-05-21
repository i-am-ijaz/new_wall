import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/providers/wallapers_provider.dart';
import 'package:new_wall/ui/widgets/wallpaper_widget.dart';

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

    _scrollController.addListener(scrollListener);
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

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
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
            child: wallpapersProvider.wallPapers().isEmpty
                ? const Center(
                    child: Text('No trending images found'),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        GridView.builder(
                          itemCount: wallpapersProvider.wallPapers().length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 5 / 7,
                          ),
                          itemBuilder: (context, index) {
                            var wallpaper =
                                wallpapersProvider.wallPapers()[index];
                            final isFav = ref
                                .watch(favProvider)
                                .isFav(wallpapersProvider.wallPapers()[index]);

                            return AspectRatio(
                              aspectRatio: index.isOdd ? 1 : 1.5,
                              child: WallpaperWidget(
                                wallpaper: wallpaper,
                                isFav: isFav,
                                wallpaperList: wallpapersProvider.wallPapers(),
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

  void scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent / 2 &&
        !_scrollController.position.outOfRange) {
      if (ref.read(wallapersProvider).hasNext) {
        ref.read(wallapersProvider).fetchNextWalls();
      }
    }
  }
}
