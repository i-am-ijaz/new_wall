import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_wall/screens/view_wallpaper/view_wallpaper.dart';

class CategoryWallpapers extends StatefulWidget {
  const CategoryWallpapers({Key? key, required this.category})
      : super(key: key);
  final String category;
  @override
  State<CategoryWallpapers> createState() => _CategoryWallpapersState();
}

class _CategoryWallpapersState extends State<CategoryWallpapers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category[0].toUpperCase() + widget.category.substring(1),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('wallpapers').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final categoryWallpapers = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
            return data['tag'] == widget.category;
          });
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: categoryWallpapers.length,
            itemBuilder: (context, index) {
              final wall = categoryWallpapers.elementAt(index);
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewWallScreen(
                        imageUrl: wall['url'],
                      ),
                    ),
                  );
                },
                child: GridTile(
                  child: Hero(
                    tag: wall['url'],
                    child: CachedNetworkImage(imageUrl: wall['url']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
