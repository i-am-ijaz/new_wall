import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:getwidget/getwidget.dart';
import 'package:new_wall/services/notification_service.dart';
import 'package:new_wall/ui/theme/colors.dart';
import 'package:new_wall/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/providers/fav_wallpaper_provider.dart';

final isVisibleProvider = StateProvider<bool>((ref) {
  return false;
});

// ignore: must_be_immutable
class ViewWallpaper extends ConsumerStatefulWidget {
  ViewWallpaper({
    Key? key,
    required this.wallpapers,
    required this.initialPage,
  }) : super(key: key);
  final List<Wallpaper> wallpapers;
  int initialPage;

  @override
  ConsumerState createState() => _ViewWallpaperState();
}

class _ViewWallpaperState extends ConsumerState<ViewWallpaper>
    with TickerProviderStateMixin {
  late PageController _pageController;
  double _fileDownloadProgress = 0.0;

  bool _isDownloading = false;
  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(_controller);

    _pageController = PageController(initialPage: widget.initialPage);
    _controller.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(favProvider);
    final isFav = provider.isFav(widget.wallpapers[widget.initialPage]);
    final isVisible = ref.watch(isVisibleProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          child: !isVisible
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  leadingWidth: 80,
                  leading: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
      body: GestureDetector(
        onTap: () => _onWallperTap(isVisible),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.wallpapers.length,
              onPageChanged: (index) {
                setState(() {
                  widget.initialPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Hero(
                  tag: widget.wallpapers[index].url,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 2.0,
                    scaleEnabled: true,
                    child: CachedNetworkImage(
                      imageUrl: widget.wallpapers[index].url,
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
            if (_fileDownloadProgress > 0)
              FileDownloadingProgress(progress: _fileDownloadProgress),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: Curves.fastOutSlowIn,
              child: !isVisible
                  ? WallBottomActions(
                      isFav: isFav,
                      onDownload: _onDownload,
                      onSetAs: _onSetAs,
                      offset: _offset,
                      onFavorities: () {
                        _addRemoveToFavorities(isFav, provider);
                      },
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  void _onWallperTap(bool isVisible) {
    ref.read(isVisibleProvider.notifier).update((state) => !state);
    if (isVisible) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
    }
  }

  void _addRemoveToFavorities(bool fav, FavWallpaperProvider provider) {
    var wallpaper = widget.wallpapers[widget.initialPage];
    fav ? provider.removeFromFav(wallpaper) : provider.addToFav(wallpaper);
  }

  Future<void> _onDownload() async {
    if (_fileDownloadProgress > 0) {
      return;
    }
    if (_isDownloading) {
      return;
    }

    String url = widget.wallpapers[widget.initialPage].url;

    await _downloadWallpaper(url);
  }

  Future<File?> _downloadWallpaper(String url) async {
    setState(() {
      _isDownloading = true;
    });

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

          await NotificationService().showNotification(
            id: downloaded,
            title: 'New Wall',
            body: 'Wallpaper downloaded successfully! Tap to open',
            payload: file.path,
          );
          await _saveImageToGallery(file);

          setState(() {
            _fileDownloadProgress = 0;
          });
          return;
        });
      });
    }

    setState(() {
      _isDownloading = false;
    });

    return file;
  }

  Future<void> _saveImageToGallery(File file) async {
    try {
      await GallerySaver.saveImage(
        file.path,
        albumName: 'New Wall',
      );
    } catch (e) {
      log(e.toString());
    }
  }

  String getFileName(String url) {
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
    var matches = regExp.allMatches(url);
    var match = matches.elementAt(0);
    return Uri.decodeFull(match.group(2)!);
  }

  Future<void> _onSetAs() async {
    await setWallpaperBottomSheet(
      context,
      widget.wallpapers[widget.initialPage].url,
    );
  }
}

class FileDownloadingProgress extends StatelessWidget {
  const FileDownloadingProgress({
    super.key,
    required this.progress,
  });
  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: size.height * 0.15,
        width: size.width * 0.4,
        child: Card(
          child: GFProgressBar(
            percentage: progress,
            radius: 80,
            lineHeight: 20,
            type: GFProgressType.circular,
            backgroundColor: Colors.black26,
            progressBarColor: primary,
            child: Text(
              '${(progress * 100).ceil()}%',
            ),
          ),
        ),
      ),
    );
  }
}

class WallBottomActions extends StatelessWidget {
  const WallBottomActions({
    super.key,
    required this.isFav,
    required this.onDownload,
    required this.onSetAs,
    required this.offset,
    required this.onFavorities,
  });
  final bool isFav;
  final VoidCallback onDownload;
  final VoidCallback onSetAs;
  final Animation<Offset> offset;
  final VoidCallback onFavorities;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 24,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: offset,
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(primary),
                  ),
                  onPressed: onDownload,
                  icon: const Icon(
                    Icons.download,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: onSetAs,
                    child: const Text("SET AS"),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: isFav
                      ? const Icon(
                          Icons.favorite,
                          color: primary,
                          size: 30,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          color: primary,
                          size: 30,
                        ),
                  onPressed: onFavorities,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
