import 'package:artbooking/components/popup_menu_item_icon.dart';
import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class AvatarMenu extends StatelessWidget {
  final bool isSmall;
  final EdgeInsets padding;

  const AvatarMenu({
    Key? key,
    this.isSmall = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arrStr = stateUser.username!.split(' ');
    String initials = '';

    if (arrStr.length > 0) {
      initials = arrStr.length > 1
          ? arrStr.reduce((value, element) => value + element.substring(1))
          : arrStr.first;

      if (initials.isNotEmpty) {
        initials = initials.substring(0, 1);
      }
    }

    return Padding(
      padding: padding,
      child: PopupMenuButton<PageRouteInfo>(
        icon: Material(
          elevation: 4.0,
          shape: CircleBorder(),
          child: CircleAvatar(
            backgroundColor: stateColors.lightBackground,
            radius: 20.0,
            backgroundImage: NetworkImage(stateUser.userFirestore.getPP()),
          ),
        ),
        onSelected: (route) {
          if (route.routeName == SignOutRoute.name) {
            stateUser.signOut(context: context);
            return;
          }

          context.router.root.push(route);
        },
        itemBuilder: itemBuilder,
      ),
    );
  }

  List<PopupMenuEntry<PageRouteInfo<dynamic>>> itemBuilder(
    BuildContext context,
  ) {
    return [
      if (isSmall) ...[
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.plus, color: Colors.black87),
          textLabel: "upload".tr(),
          value: DashboardPageRoute(children: []),
        ),
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.search, color: Colors.black87),
          textLabel: "search".tr(),
          value: SearchPageRoute(),
        ),
      ],
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.chart_pie, color: Colors.black87),
        textLabel: "activity_my".tr(),
        value: DashboardPageRoute(
          children: [MyActivityPageRoute()],
        ),
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.picture, color: Colors.black87),
        textLabel: "illustrations_my".tr(),
        value: DashboardPageRoute(children: [
          DashIllustrationsRouter(children: [MyIllustrationsPageRoute()])
        ]),
      ),
      PopupMenuItemIcon(
        value: DashboardPageRoute(children: [
          DashBooksRouter(children: [MyBooksPageRoute()])
        ]),
        icon: Icon(UniconsLine.book_alt, color: Colors.black87),
        textLabel: "books_my".tr(),
      ),
      PopupMenuItemIcon(
        value: DashboardPageRoute(children: [DashProfileRouter()]),
        icon: Icon(UniconsLine.user, color: Colors.black87),
        textLabel: "profile_my".tr(),
      ),
      PopupMenuItemIcon(
        value: SignOutRoute(),
        icon: Icon(UniconsLine.sign_left, color: Colors.black87),
        textLabel: "signout".tr(),
      ),
    ];
  }
}
