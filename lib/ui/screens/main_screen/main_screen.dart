import 'package:flutter/material.dart';

import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

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

  int _currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "New Wall",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Wallpaper>>(
        stream: FirestoreService.wallpapers(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Wallpaper>> wallpapersSnapshot,
        ) {
          if (wallpapersSnapshot.hasData) {
            List<Wallpaper> wallpapers = wallpapersSnapshot.requireData;

            return PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() => _currentPageIndex = page);
              },
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return _currentPage(index, wallpapers);
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentPage: _currentPageIndex,
        pageController: _pageController,
      ),
    );
  }

  Widget _currentPage(int index, List<Wallpaper> wallpaperList) {
    switch (index) {
      case 0:
        return const TrendingScreen();
      case 1:
        return CategoryScreen(wallpaperList: wallpaperList);
      case 2:
        return FavoritiesScreen(wallpapersList: wallpaperList);
      default:
        return const CircularProgressIndicator();
    }
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    Key? key,
    required int currentPage,
    required PageController pageController,
  })  : _currentPage = currentPage,
        _pageController = pageController,
        super(key: key);

  final int _currentPage;
  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentPage,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.white,
      onTap: (i) {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.image_outlined),
          activeIcon: Icon(Icons.image),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: '',
        ),
      ],
    );
  }
}
