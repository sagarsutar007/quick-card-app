import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:quickcard/core/services/connectivity_service.dart';
import 'package:quickcard/core/services/locator.dart';
import 'package:quickcard/core/router.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickcard/shared/models/photo_upload.dart';
import 'package:quickcard/shared/utils/photo_upload_queue.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  Hive.registerAdapter(PhotoUploadAdapter());
  await Hive.openBox<PhotoUpload>('photo_uploads');

  await setupLocator();

  final photoUploadQueue = await getIt.getAsync<PhotoUploadQueue>();
  final connectivityService = getIt<ConnectivityService>();

  connectivityService.startMonitoring(() {
    photoUploadQueue.processQueue();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QuickCard',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        fontFamily: 'LeagueSpartan',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
    );
  }
}
