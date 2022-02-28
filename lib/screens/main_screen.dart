import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_wall/providers/change_theme_provider.dart';
import 'package:new_wall/screens/all_images/all_images_screen.dart';
import 'package:new_wall/screens/favorities.dart';
import 'package:new_wall/screens/home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final value = ref.watch(changeTheme);
      return Scaffold(
        appBar: AppBar(
          title: Text('New Wall'),
          actions: [
            IconButton(
              onPressed: () {
                if (value.darkMode) {
                  ref.read(changeTheme.notifier).enableLightMode();
                } else {
                  ref.read(changeTheme.notifier).enableDarkMode();
                }
              },
              icon: Icon(value.darkMode ? Icons.dark_mode : Icons.wb_sunny),
            ),
          ],
        ),
        body: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('wallpapers').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    currentPage = page;
                  });
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
    });
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
