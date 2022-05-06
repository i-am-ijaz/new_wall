import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/utils/utils.dart';

// ignore: must_be_immutable
class ViewWallpaper extends ConsumerStatefulWidget {
  ViewWallpaper({
    Key? key,
    required this.wallpapersList,
    required this.initialPage,
  }) : super(key: key);
  final List<Wallpaper> wallpapersList;
  int initialPage;
  @override
  ConsumerState createState() => _ViewWallpaperState();
}

class _ViewWallpaperState extends ConsumerState<ViewWallpaper> {
  File? file;

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: widget.wallpapersList.length,
            onPageChanged: (index) {
              setState(() {
                widget.initialPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Hero(
                tag: widget.wallpapersList[index].url,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 2.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.wallpapersList[index].url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: size.height * 0.1,
                width: size.width * 0.4,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Color(IconTheme.of(context).color!.value ^ 0xFFFFFFFF),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        String url =
                            widget.wallpapersList[widget.initialPage].url;

                        file = await downloadWallpaper(url);
                        if (file != null) {
                          SnackBar(
                            content: const Text(
                              'Wallpaper downloaded successfully',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            action: SnackBarAction(
                              label: 'Open',
                              onPressed: () async {
                                await openFile(
                                  file: file!,
                                );
                              },
                            ),
                          );

                          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      icon: const Icon(
                        Icons.download,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.format_paint,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await setWallpaperBottomSheet(
                          context,
                          widget.wallpapersList[widget.initialPage.toInt()].url,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
