import 'package:flutter/material.dart';
import 'package:new_wall/ui/theme/colors.dart';

class ProgressDialogContent extends StatelessWidget {
  const ProgressDialogContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              primary,
            ),
          ),
        ),
      ),
    );
  }
}
