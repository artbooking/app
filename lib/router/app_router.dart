import 'package:artbooking/components/hero_empty_router_page.dart';
import 'package:artbooking/router/auth_guard.dart';
import 'package:artbooking/router/no_auth_guard.dart';
import 'package:artbooking/screens/about_page.dart';
import 'package:artbooking/screens/changelog_page.dart';
import 'package:artbooking/screens/contact_page.dart';
import 'package:artbooking/screens/dashboard_page.dart';
import 'package:artbooking/screens/delete_account_page.dart';
import 'package:artbooking/screens/edit_image_page.dart';
import 'package:artbooking/screens/forgot_password_page.dart';
import 'package:artbooking/screens/home_page.dart';
import 'package:artbooking/screens/illustration_page.dart';
import 'package:artbooking/screens/illustrations_page.dart';
import 'package:artbooking/screens/my_book_page.dart';
import 'package:artbooking/screens/my_books_page.dart';
import 'package:artbooking/screens/my_illustrations_page.dart';
import 'package:artbooking/screens/my_profile_page.dart';
import 'package:artbooking/screens/search_page.dart';
import 'package:artbooking/screens/settings_page.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/screens/signup_page.dart';
import 'package:artbooking/screens/my_activity_page.dart';
import 'package:artbooking/screens/tos_page.dart';
import 'package:artbooking/screens/undefined_page.dart';
import 'package:artbooking/screens/update_email_page.dart';
import 'package:artbooking/screens/update_password_page.dart';
import 'package:artbooking/screens/update_username_page.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

// export 'app_router.gr.dart';

@MaterialAutoRouter(
  routes: [
    CustomRoute(
      path: '/',
      page: HomePage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '/about',
      page: AboutPage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '/changelog',
      page: ChangelogPage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '/contact',
      page: ContactPage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '/dashboard',
      page: DashboardPage,
      guards: [AuthGuard],
      transitionsBuilder: TransitionsBuilders.fadeIn,
      children: [
        MaterialRoute(
          path: 'activity',
          page: MyActivityPage,
        ),
        MaterialRoute(
          path: 'illustrations',
          name: 'DashIllustrationsRouter',
          page: HeroEmptyRouterPage,
          children: [
            CustomRoute(
              path: '',
              page: MyIllustrationsPage,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
            CustomRoute(
              path: ':illustrationId',
              name: 'DashIllustrationPage',
              page: IllustrationPage,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),

            // CustomRoute(
            //   path: 'edit/:illustrationId',
            //   page: EditIllustrationPage,
            //   transitionsBuilder: TransitionsBuilders.fadeIn,
            // ),

            RedirectRoute(path: '*', redirectTo: ''),
          ],
        ),
        CustomRoute(
          path: 'books',
          name: 'DashBooksRouter',
          page: HeroEmptyRouterPage,
          transitionsBuilder: autoRouteTransitionBuilder,
          customRouteBuilder: autoRoutePageBuilder,
          children: [
            CustomRoute(
              path: '',
              page: MyBooksPage,
              transitionsBuilder: autoRouteTransitionBuilder,
              customRouteBuilder: autoRoutePageBuilder,
            ),
            CustomRoute(
              path: ':bookId',
              name: 'DashBookPage',
              page: MyBookPage,
              transitionsBuilder: autoRouteTransitionBuilder,
              customRouteBuilder: autoRoutePageBuilder,
            ),
            RedirectRoute(path: '*', redirectTo: ''),
          ],
        ),
        MaterialRoute(
          path: 'profile',
          name: 'DashProfileRouter',
          page: EmptyRouterPage,
          children: [
            CustomRoute(
              path: '',
              page: MyProfilePage,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
            CustomRoute(
              path: 'edit/pp',
              page: EditImagePage,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
            RedirectRoute(path: '*', redirectTo: ''),
          ],
        ),
        CustomRoute(
          path: 'settings',
          page: EmptyRouterPage,
          name: 'DashSettingsRouter',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              path: '',
              page: SettingsPage,
              name: 'DashSettingsRoute',
            ),
            CustomRoute(
              path: 'delete/account',
              page: DeleteAccountPage,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
            CustomRoute(
              path: 'update',
              page: EmptyRouterPage,
              name: 'DashAccountUpdateRouter',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              children: [
                CustomRoute(path: 'email', page: UpdateEmailPage),
                CustomRoute(path: 'password', page: UpdatePasswordPage),
                CustomRoute(path: 'username', page: UpdateUsernamePage),
              ],
            ),
          ],
        ),
        RedirectRoute(path: '', redirectTo: 'activity'),
      ],
    ),
    MaterialRoute(path: '/forgotpassword', page: ForgotPasswordPage),
    CustomRoute(
      path: '/illustrations',
      page: EmptyRouterPage,
      name: 'IllustrationsRouter',
      transitionsBuilder: TransitionsBuilders.fadeIn,
      children: [
        MaterialRoute(path: '', page: IllustrationsPage),
        MaterialRoute(path: ':illustrationId', page: IllustrationPage),
      ],
    ),
    CustomRoute(
      path: '/search',
      page: SearchPage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '/settings',
      page: SettingsPage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '/signin',
      page: SigninPage,
      guards: [NoAuthGuard],
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '/signup',
      page: SignupPage,
      guards: [NoAuthGuard],
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    MaterialRoute(
      path: '/signout',
      page: EmptyRouterPage,
      name: 'SignOutRoute',
    ),
    AutoRoute(
      path: '/ext',
      page: EmptyRouterPage,
      name: 'ExtRouter',
      children: [
        MaterialRoute(
          path: 'github',
          page: EmptyRouterPage,
          name: 'GitHubRoute',
        ),
        // MaterialRoute(
        //   path: 'android',
        //   page: EmptyRouterPage,
        //   name: 'AndroidAppRoute',
        // ),
        // MaterialRoute(
        //   path: 'ios',
        //   page: EmptyRouterPage,
        //   name: 'IosAppRoute',
        // ),
      ],
    ),
    CustomRoute(
      path: '/tos',
      page: TosPage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      path: '*',
      page: UndefinedPage,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
  ],
)
class $AppRouter {}

Widget autoRouteTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return child;
}

Route<bool> autoRoutePageBuilder<bool>(
  BuildContext context,
  Widget child,
  CustomPage page,
) {
  return PageRouteBuilder(
    settings: page,
    pageBuilder: (context, animation, secondaryAnimation) {
      return child;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
