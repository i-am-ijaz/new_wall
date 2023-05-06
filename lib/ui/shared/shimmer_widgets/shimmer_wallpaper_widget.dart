import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWallpaperWidget extends StatelessWidget {
  const ShimmerWallpaperWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      children: List.generate(
        12,
        (index) {
          return StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: index.isEven ? 2.5 : 3,
            child: Shimmer.fromColors(
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              baseColor: Colors.red,
              highlightColor: Colors.yellow,
            ),
          );
        },
      ),
      axisDirection: AxisDirection.down,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }
}
