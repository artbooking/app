import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/storage_keys.dart';
import 'package:flutter/widgets.dart';

class NavigationHelper {
  static GlobalKey<NavigatorState>? navigatorKey;

  static void clearSavedNotifiData() {
    appStorage.setString(StorageKeys.quoteIdNotification, '');
    appStorage.setString(StorageKeys.onOpenNotificationPath, '');
  }

  // static void navigateNextFrame(
  //   PageRouteInfo pageRoute,
  //   BuildContext context,
  // ) {
  //   SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
  //     context.vRouter.push(pageRoute);
  //   });
  // }

  // static PageRouteInfo getSettingsRoute() {
  //   if (stateUser.isUserConnected) {
  //     return DashboardPageRoute(children: [DashSettingsRouter()]);
  //   }

  //   return SettingsPageRoute();
  // }
}
