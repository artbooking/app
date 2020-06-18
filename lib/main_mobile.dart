import 'package:artbooking/router/router.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class MainMobile extends StatefulWidget {
  @override
  MainMobileState createState() => MainMobileState();
}

class MainMobileState extends State<MainMobile> {
  @override
  void initState() {
    super.initState();
    checkConnection();
    loadBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Out Of Context',
      theme: stateColors.themeData,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: FluroRouter.router.generator,
    );
  }

  void checkConnection() async {
    final hasConnection = await DataConnectionChecker().hasConnection;

    if (!hasConnection) {
      showSnack(
        context: context,
        message: "It seems that you're offline",
        type: SnackType.error,
      );
    }
  }

  void loadBrightness() {
    final now = DateTime.now();

    Brightness brightness = Brightness.light;

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    Future.delayed(
      2.seconds,
      () {
        try {
          DynamicTheme.of(context).setBrightness(brightness);
          stateColors.refreshTheme(brightness);

        } catch (error) {
          debugPrint(error.toString());
        }
      }
    );
  }
}
