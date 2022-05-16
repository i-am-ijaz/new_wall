import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  double fileDownloadProgress = 0.0;

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
    final provider = ref.watch(favProvider);
    var fav = provider.isFav(widget.wallpapersList[widget.initialPage]);
    return Scaffold(
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
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: kToolbarHeight,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: fav
                                ? const Icon(Icons.favorite)
                                : const Icon(Icons.favorite_border),
                            onPressed: () {
                              var wallpaper =
                                  widget.wallpapersList[widget.initialPage];
                              fav
                                  ? provider.removeFromFav(wallpaper)
                                  : provider.addToFav(wallpaper);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (fileDownloadProgress != 0.0)
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: fileDownloadProgress,
                    backgroundColor: Colors.white,
                    color: Colors.white,
                    strokeWidth: 5,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Downloading... \n ${fileDownloadProgress.toInt().toString()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
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

                        final snackBar = SnackBar(
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

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  Future<File> downloadWallpaper(String url) async {
    var status = await Permission.storage.request();

    String dir = (await getApplicationDocumentsDirectory()).path;
    String fileName = getFileName(url);
    File file = File('$dir/$fileName');

    if (status.isGranted) {
      var httpClient = http.Client();
      var request = http.Request('GET', Uri.parse(url));
      var response = httpClient.send(request);

      List<List<int>> chunks = [];
      int downloaded = 0;

      response.asStream().listen((http.StreamedResponse r) {
        r.stream.listen((List<int> chunk) {
          setState(() {
            fileDownloadProgress = downloaded / r.contentLength! * 100;
          });
          chunks.add(chunk);
          downloaded += chunk.length;
        }, onDone: () async {
          setState(() {
            fileDownloadProgress = downloaded / r.contentLength! * 100;
          });

          final Uint8List bytes = Uint8List(r.contentLength!);
          int offset = 0;
          for (List<int> chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }
          await file.writeAsBytes(bytes);

          await saveImageToGallery(file);

          return;
        });
      });
    }
    return file;
  }

  Future<File> saveImageToGallery(File file) async {
    try {
      final isSaved = await GallerySaver.saveImage(
        file.path,
        albumName: 'New Wall',
      );
      log(isSaved.toString());
    } catch (e) {
      log(e.toString());
    }
    return file;
  }

  String getFileName(String url) {
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
    var matches = regExp.allMatches(url);
    var match = matches.elementAt(0);
    return Uri.decodeFull(match.group(2)!);
  }
}
