import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/change_theme_provider.dart';

class CustomAppBar extends ConsumerWidget with PreferredSizeWidget {
  const CustomAppBar({Key? key})
      : preferredSize = const Size.fromHeight(50),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(changeTheme);

    return AppBar(
      title: const Text('New Wall'),
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
    );
  }
}
