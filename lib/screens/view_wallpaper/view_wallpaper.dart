import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper/wallpaper.dart';

class ViewWallScreen extends StatefulWidget {
  const ViewWallScreen({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);
  final String imageUrl;

  @override
  State<ViewWallScreen> createState() => _ViewWallScreenState();
}

class _ViewWallScreenState extends State<ViewWallScreen> {
  Stream<String>? progressString;
  String res = '';
  bool downloading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Hero(
              tag: widget.imageUrl,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: FloatingActionButton(
              child: const Icon(Icons.wallpaper),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 140.0),
                              child: Divider(
                                thickness: 5,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              'Set as',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                  child: const Text('Home Screen'),
                                  onPressed: () async {
                                    await dowloadImage(
                                      context,
                                      widget.imageUrl,
                                    );
                                    // await imageDownloadDialog();
                                    final home = await Wallpaper.homeScreen(
                                      options: RequestSizeOptions.RESIZE_FIT,
                                      width: size.width,
                                      height: size.height,
                                    );
                                    setState(() {
                                      downloading = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Lock Screen'),
                                  onPressed: () async {
                                    await Wallpaper.lockScreen(
                                      options: RequestSizeOptions.RESIZE_FIT,
                                      width: size.width,
                                      height: size.height,
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Both'),
                                  onPressed: () async {
                                    await Wallpaper.bothScreen(
                                      options: RequestSizeOptions.RESIZE_FIT,
                                      width: size.width,
                                      height: size.height,
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> dowloadImage(BuildContext context, String imageUrl) async {
    progressString = Wallpaper.imageDownloadProgress(imageUrl);
    print(progressString);
    progressString!.listen((data) {
      setState(() {
        res = data;
        downloading = true;
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      setState(() {
        downloading = false;

        // _isDisable = false;
      });
      print("Task Done");
    }, onError: (error) {
      setState(() {
        downloading = false;
        // _isDisable = true;
      });
      print("Some Error");
    });
  }

  imageDownloadDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 120.0,
            width: 200.0,
            child: Card(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20.0),
                  Text(
                    "Downloading File : $res",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          );
        });
  }
}
