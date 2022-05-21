import 'package:flutter/material.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_wall/services/firestore_service.dart';

import 'categories/categories_screen.dart';
import 'favorities/favorities.dart';
import 'trendings/trending_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final PageController _pageController = PageController(initialPage: 1);

  int currentPage = 1;

  Stream<QuerySnapshot<Map<String, dynamic>>> wallpapersStream() =>
      FirebaseFirestore.instance.collection('wallpapers').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: const CustomAppBar(),
      body: StreamBuilder<List<Wallpaper>>(
        stream: FirestoreService.wallpapers(),
        builder: (
          BuildContext context,
          snapshot,
        ) {
          if (snapshot.hasData) {
            List<Wallpaper> wallpapers = snapshot.data!.toList();

            return PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() => currentPage = page);
              },
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return _getPages(index, wallpapers);
              },
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      bottomNavigationBar: navigationBar(),
    );
  }

  Widget _getPages(int index, List<Wallpaper> wallpaperList) {
    switch (index) {
      case 0:
        return const TrendingScreen();
      case 1:
        return CategoryScreen(wallpaperList: wallpaperList);
      case 2:
        return FavoritiesScreen(wallpaperList: wallpaperList);
      default:
        return const CircularProgressIndicator();
    }
  }

  Widget navigationBar() {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Colors.green.shade100,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentPage,
        backgroundColor: Colors.white,
        animationDuration: const Duration(seconds: 2),
        onDestinationSelected: (int i) {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.image_outlined),
            selectedIcon: Icon(Icons.image),
            label: 'Trending',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorities',
          ),
        ],
      ),
    );
  }
}
