import 'package:artbooking/state/user.dart';
import 'package:auto_route/auto_route.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (stateUser.isUserConnected) {
      resolver.next(true);
      return;
    }

    // router.root.push(
    //   SigninPageRoute(onSigninResult: (isAuthenticated) {
    //     if (isAuthenticated) {
    //       router.replaceAll(
    //         resolver.pendingRoutes.map((route) => route.toRoute()).toList(),
    //       );
    //     }
    //   }),
    // );
  }
}
