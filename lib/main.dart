import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/router/auth_guard.dart';
import 'package:artbooking/router/no_auth_guard.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/brightness.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await appStorage.initialize();
  await Future.wait([_autoLogin(), _initLang()]);

  final brightness = BrightnessUtils.getCurrent();

  final savedThemeMode = brightness == Brightness.dark
      ? AdaptiveThemeMode.dark
      : AdaptiveThemeMode.light;

  setPathUrlStrategy();

  return runApp(App(
    savedThemeMode: savedThemeMode,
    brightness: brightness,
  ));
}

/// Main app class.
class App extends StatefulWidget {
  final AdaptiveThemeMode savedThemeMode;
  final Brightness brightness;

  const App({
    Key key,
    this.savedThemeMode,
    this.brightness,
  }) : super(key: key);

  AppState createState() => AppState();
}

/// Main app class state.
class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    stateColors.refreshTheme(widget.brightness);
    stateUser.setFirstLaunch(appStorage.isFirstLanch());

    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      initial: widget.brightness == Brightness.light
          ? AdaptiveThemeMode.light
          : AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) {
        stateColors.themeData = theme;

        return AppWithTheme(
          brightness: widget.brightness,
          theme: theme,
          darkTheme: darkTheme,
        );
      },
    );
  }
}

/// Because we need a [context] with adaptive theme data available in it.
class AppWithTheme extends StatefulWidget {
  final ThemeData theme;
  final ThemeData darkTheme;
  final Brightness brightness;

  const AppWithTheme({
    Key key,
    @required this.brightness,
    @required this.darkTheme,
    @required this.theme,
  }) : super(key: key);

  @override
  _AppWithThemeState createState() => _AppWithThemeState();
}

class _AppWithThemeState extends State<AppWithTheme> {
  final appRouter = AppRouter(
    // adminAuthGuard: AdminAuthGuard(),
    authGuard: AuthGuard(),
    noAuthGuard: NoAuthGuard(),
  );

  @override
  initState() {
    super.initState();
    Future.delayed(250.milliseconds, () {
      if (widget.brightness == Brightness.dark) {
        AdaptiveTheme.of(context).setDark();
        return;
      }

      AdaptiveTheme.of(context).setLight();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ArtBooking',
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      debugShowCheckedModeBanner: false,
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}

// Initialization functions.
// ------------------------
Future _autoLogin() async {
  try {
    final userCred = await stateUser.signin();

    if (userCred == null) {
      stateUser.signOut();
    }
  } catch (error) {
    appLogger.e(error);
    stateUser.signOut();
  }
}

Future _initLang() async {
  final savedLang = appStorage.getLang();
  stateUser.setLang(savedLang);
}
