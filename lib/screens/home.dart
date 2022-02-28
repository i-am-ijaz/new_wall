import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_wall/screens/category_wallpapers/category_wallpapers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.snapshot,
  }) : super(key: key);
  final AsyncSnapshot<QuerySnapshot> snapshot;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> categories = [];
  List<String> categoryImages = [];

  @override
  void initState() {
    super.initState();
    widget.snapshot.data!.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      var category = data['tag'];
      // print(category);
      if (!categories.contains(category)) {
        categories.add(category);
        categoryImages.add(data['url']);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
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
                    categoryImages[index],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index].toUpperCase(),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryWallpapers(
                    category: categories[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
