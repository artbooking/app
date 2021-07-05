import 'package:artbooking/router/app_router_nav_args.dart';
import 'package:artbooking/screens/about_page.dart';
import 'package:artbooking/screens/changelog_page.dart';
import 'package:artbooking/screens/contact_page.dart';
import 'package:artbooking/screens/dashboard_page.dart';
import 'package:artbooking/screens/delete_account_page.dart';
import 'package:artbooking/screens/edit_image_page.dart';
import 'package:artbooking/screens/forgot_password_page.dart';
import 'package:artbooking/screens/home_page.dart';
import 'package:artbooking/screens/illustration_page.dart';
import 'package:artbooking/screens/my_activity_page.dart';
import 'package:artbooking/screens/my_book_page.dart';
import 'package:artbooking/screens/my_books_page.dart';
import 'package:artbooking/screens/my_illustrations_page.dart';
import 'package:artbooking/screens/my_profile_page.dart';
import 'package:artbooking/screens/search_page.dart';
import 'package:artbooking/screens/settings_page.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/screens/signup_page.dart';
import 'package:artbooking/screens/tos_page.dart';
import 'package:artbooking/screens/update_email_page.dart';
import 'package:artbooking/screens/update_password_page.dart';
import 'package:artbooking/screens/update_username_page.dart';
import 'package:artbooking/state/user.dart';
import 'package:vrouter/vrouter.dart';

final List<VRouteElement> appRoutes = [
  VWidget(path: '/', widget: HomePage()),
  VWidget(path: '/about', widget: AboutPage()),
  VWidget(path: '/changelog', widget: ChangelogPage()),
  VWidget(path: '/contact', widget: ContactPage()),
  VGuard(
    beforeEnter: (vRedirector) async {
      return stateUser.isUserConnected ? null : vRedirector.push('/login');
    },
    stackedRoutes: [
      VNester(
        path: '/dashboard',
        widgetBuilder: (child) => DashboardPage(child: child),
        nestedRoutes: [
          VWidget(path: 'activity', widget: MyActivityPage()),
          VWidget(
            path: 'illustrations',
            widget: MyIllustrationsPage(),
            stackedRoutes: [
              VWidget(path: null, widget: MyIllustrationsPage()),
              VWidget(
                path: ':illustrationId',
                widget: IllustrationPage(
                  illustration: AppRouterNavArgs.lastIllustrationSelected,
                ),
              ),
            ],
          ),
          VWidget(
            path: 'books',
            widget: MyBooksPage(),
            stackedRoutes: [
              VWidget(path: null, widget: MyBooksPage()),
              VWidget(
                path: ':bookId',
                name: 'my_book',
                widget: MyBookPage(book: AppRouterNavArgs.lastBookSelected),
                stackedRoutes: [
                  // VWidget(
                  //   path: null,
                  //   name: 'my_book_page',
                  //   widget: MyBookPage(book: AppRouterNavArgs.lastBookSelected),
                  // ),
                  VWidget(
                    path: 'illustrations/:illustrationId',
                    widget: IllustrationPage(
                      illustration: AppRouterNavArgs.lastIllustrationSelected,
                    ),
                  ),
                ],
              ),
            ],
          ),
          VWidget(
            path: 'profile',
            widget: MyProfilePage(),
            stackedRoutes: [
              VWidget(path: null, widget: MyProfilePage()),
              VWidget(
                path: 'edit/pp',
                widget: EditImagePage(
                  image: AppRouterNavArgs.lastEditImageSelected,
                ),
              ),
            ],
          ),
          VWidget(
            path: 'settings',
            widget: SettingsPage(),
            stackedRoutes: [
              VWidget(path: null, widget: SettingsPage()),
              VWidget(path: 'delete/account', widget: DeleteAccountPage()),
              VWidget(
                path: 'update',
                widget: UpdateEmailPage(),
                stackedRoutes: [
                  VWidget(path: 'email', widget: UpdateEmailPage()),
                  VWidget(path: 'password', widget: UpdatePasswordPage()),
                  VWidget(path: 'username', widget: UpdateUsernamePage()),
                  VRouteRedirector(path: ':_(.+)', redirectTo: 'email'),
                ],
              ),
            ],
          ),
          VRouteRedirector(path: ':_(.+)', redirectTo: 'activity'),
        ],
      ),
    ],
  ),
  VWidget(path: '/forgotpassword', widget: ForgotPasswordPage()),
  VWidget(path: '/search', widget: SearchPage()),
  VWidget(path: '/signin', widget: SigninPage()),
  VWidget(path: '/signup', widget: SignupPage()),
  VWidget(path: '/tos', widget: TosPage()),
  VRouteRedirector(path: ':_(.+)', redirectTo: '/'),
];
