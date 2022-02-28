import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class AllImagesScreen extends StatefulWidget {
  const AllImagesScreen({Key? key, required this.snapshot}) : super(key: key);
  final AsyncSnapshot<QuerySnapshot> snapshot;

  @override
  State<AllImagesScreen> createState() => _AllImagesScreenState();
}

class _AllImagesScreenState extends State<AllImagesScreen> {
  CollectionReference wallpapers =
      FirebaseFirestore.instance.collection('wallpapers');

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      children: widget.snapshot.data!.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: GridTile(
            child: CachedNetworkImage(
              imageUrl: data['url'],
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }
}
