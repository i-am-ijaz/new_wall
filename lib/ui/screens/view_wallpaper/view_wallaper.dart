import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';
import 'package:new_wall/ui/screens/view_wallpaper/components/view_wall_app_bar.dart';
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
  late PageController _pageController;
  double _fileDownloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            controller: _pageController,
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
          ViewWallAppBar(
            isFav: fav,
            setFavorities: () => addRemoveToFavorities(fav, provider),
          ),
          if (_fileDownloadProgress > 0)
            SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 80,
                  child: GFProgressBar(
                    percentage: _fileDownloadProgress,
                    width: 100,
                    radius: 80,
                    lineHeight: 20,
                    type: GFProgressType.circular,
                    backgroundColor: Colors.black26,
                    progressBarColor: GFColors.DANGER,
                    child: Center(
                      child: Text(
                        '${(_fileDownloadProgress * 100).ceil()}%',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  height: size.height * 0.1,
                  width: size.width * 0.4,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.green.shade100,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          String url =
                              widget.wallpapersList[widget.initialPage].url;

                          final file = await downloadWallpaper(url);
                          await showFileOpenSnackbar(file, context);
                        },
                        icon: const Icon(
                          Icons.download,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.format_paint,
                          size: 30,
                        ),
                        onPressed: () async => await setWallpaperBottomSheet(
                          context,
                          widget.wallpapersList[widget.initialPage].url,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showFileOpenSnackbar(File file, BuildContext context) async {
    Future.delayed(const Duration(seconds: 3), () {
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
              file: file,
            );
          },
        ),
      );
      if (_fileDownloadProgress == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  void addRemoveToFavorities(bool fav, FavWallpaperProvider provider) {
    var wallpaper = widget.wallpapersList[widget.initialPage];
    fav ? provider.removeFromFav(wallpaper) : provider.addToFav(wallpaper);
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
            _fileDownloadProgress = downloaded / r.contentLength!;
          });
          chunks.add(chunk);
          downloaded += chunk.length;
        }, onDone: () async {
          setState(() {
            _fileDownloadProgress = downloaded / r.contentLength!;
          });

          final Uint8List bytes = Uint8List(r.contentLength!);
          int offset = 0;
          for (List<int> chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }
          await file.writeAsBytes(bytes);

          await saveImageToGallery(file);

          setState(() {
            _fileDownloadProgress = 0;
          });
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
