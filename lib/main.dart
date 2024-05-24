import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:skripsyit/data/api/controller/sensor_controller.dart';
import 'package:skripsyit/data/local/db/sensor_db.dart';
import 'package:skripsyit/data/local/model/sensor.dart';
import 'package:skripsyit/firebase_options.dart';
import 'package:skripsyit/utils/shared_prefs.dart';
import 'package:skripsyit/views/views.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init Hive
  Hive.registerAdapter(SensorAdapter());
  await SensorDB.init();

  // Init shared preferences
  await SharedPreferenceService.init();
  Get.put(SensorController(), permanent: true);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      ensureScreenSize: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        home: const MoniFloraSplashViews(),
      ),
    );
  }
}

class MoniFloraSplashViews extends StatefulWidget {
  const MoniFloraSplashViews({super.key});

  @override
  State<MoniFloraSplashViews> createState() => _MoniFloraSplashViewsState();
}

class _MoniFloraSplashViewsState extends State<MoniFloraSplashViews> {
  @override
  void initState() {
    Timer(
      const Duration(seconds: 3),
      () {
        if (FirebaseAuth.instance.currentUser != null) {
          Get.off(
            () => const HomePageViews(),
            transition: Transition.leftToRight,
          );
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AuthPageViews(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.sh,
      width: 1.sw,
      child: Image.asset(
        'assets/splashscreen-bg.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
