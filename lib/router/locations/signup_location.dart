import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/signup_page.dart';
import 'package:artbooking/state/user.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class SignupLocation extends BeamLocation {
  /// Main root value for this location.
  static const String route = '/signup';

  @override
  List<String> get pathBlueprints => [route];

  /// Redirect to home ('/') if the user is authenticated.
  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathBlueprints: [route],
          check: (context, location) => !stateUser.isUserConnected,
          beamToNamed: HomeLocation.route,
        ),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SignupPage(),
        key: ValueKey(route),
        title: "Signup",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
