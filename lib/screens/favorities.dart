import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoritiesScreen extends StatefulWidget {
  const FavoritiesScreen({
    Key? key,
    required this.snapshot,
  }) : super(key: key);
  final AsyncSnapshot<QuerySnapshot> snapshot;
  @override
  State<FavoritiesScreen> createState() => _FavoritiesScreenState();
}

class _FavoritiesScreenState extends State<FavoritiesScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Favorities'),
    );
  }
}
