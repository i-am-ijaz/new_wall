import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';

import 'category_wallpapers/category_wallpapers.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    Key? key,
    required this.wallpaperList,
  }) : super(key: key);
  final List<Wallpaper> wallpaperList;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> _categories = [];
  final List<String> _categoryImages = [];

  @override
  void initState() {
    super.initState();
    for (var wallpaper in widget.wallpaperList) {
      var category = wallpaper.tag;

      if (!_categories.contains(category)) {
        _categories.add(category);
        _categoryImages.add(wallpaper.url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _categories.isEmpty
            ? const Center(
                child: Text('No Categories Added'),
              )
            : GridView.builder(
                itemCount: _categories.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                ),
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkResponse(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              _categoryImages[index],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _categories[index].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.combine(
                              [
                                TextDecoration.underline,
                                TextDecoration.overline,
                              ],
                            ),
                            decorationStyle: TextDecorationStyle.double,
                          ),
                        ),
                      ),
                      onTap: () {
                        _viewWallpapersCaltegoryPage(context, index);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _viewWallpapersCaltegoryPage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryWallpapers(
          category: _categories[index],
        ),
      ),
    );
  }
}
