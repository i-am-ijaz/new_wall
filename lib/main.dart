import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_wall/ui/theme/theme.dart';
import 'package:new_wall/ui/widgets/constants.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';

import 'ui/screens/main_screen/main_screen.dart';

Future<void> main() async {
  await initApp();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var docDir = await getApplicationDocumentsDirectory();
  Hive.init(docDir.path);

  var favBox = await Hive.openBox(Constants.favBox);
  // await Hive.box(Constants.favBox).clear();

  if (favBox.get(Constants.favListKey) == null) {
    favBox.put(Constants.favListKey, []);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'New Wall',
      theme: AppTheme.lightTheme,
      
      home: const MainScreen(),
    );
  }
}
