import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_wall/models/wallpaper/wallpaper.dart';
import 'package:new_wall/services/firestore_service.dart';

final wallapersProvider = ChangeNotifierProvider<WallpapersProvider>((ref) {
  return WallpapersProvider();
});

class WallpapersProvider extends ChangeNotifier {
  final _wallPapersSnapshot = [];

  String _errorMsg = '';
  bool hasNext = true;
  bool _isFetching = false;
  final int _documentLimit = 15;

  String get errorMsg => _errorMsg;

  List<Wallpaper> wallPapers() {
    return _wallPapersSnapshot.map((doc) {
      return Wallpaper(
        id: doc.id,
        url: doc.data()['url'],
        tag: doc.data()['tag'],
      );
    }).toList();
  }

  Future<void> fetchNextWalls() async {
    if (_isFetching) return;
    log('fetchNextWalls');
    _errorMsg = '';
    _isFetching = true;

    try {
      final snap = await FirestoreService.getWallapers(
        _documentLimit,
        startAfter:
            _wallPapersSnapshot.isNotEmpty ? _wallPapersSnapshot.last : null,
      );
      _wallPapersSnapshot.addAll(snap.docs);

      if (snap.docs.length < _documentLimit) hasNext = false;
    } catch (e) {
      _errorMsg = e.toString();
    }

    _isFetching = false;
    notifyListeners();
  }
}
