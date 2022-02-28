import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:new_wall/ui/screens/all_images/all_images_screen.dart';
import 'package:new_wall/ui/screens/favorities/favorities.dart';
import 'package:new_wall/ui/screens/home/home.dart';
import 'package:new_wall/ui/widgets/custom_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 1);

  int currentPage = 1;

  Stream<QuerySnapshot<Map<String, dynamic>>> wallpapersStream() =>
      FirebaseFirestore.instance.collection('wallpapers').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: StreamBuilder(
        stream: wallpapersStream(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasData) {
            return PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() => currentPage = page);
              },
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return _getPages(index, snapshot);
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorities',
          ),
        ],
        onTap: (int i) {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
        },
      ),
    );
  }

  Widget _getPages(int index, AsyncSnapshot<QuerySnapshot> snapshot) {
    switch (index) {
      case 0:
        return AllImagesScreen(
          snapshot: snapshot,
        );
      case 1:
        return HomeScreen(
          snapshot: snapshot,
        );
      case 2:
        return FavoritiesScreen(
          snapshot: snapshot,
        );
      default:
        return const CircularProgressIndicator();
    }
  }
}
