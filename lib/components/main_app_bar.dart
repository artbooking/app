import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/components/avatar_menu.dart';
import 'package:artbooking/components/lang_popup_menu_button.dart';
import 'package:artbooking/components/underlined_button.dart';
import 'package:artbooking/screens/illustrations_page.dart';
import 'package:artbooking/screens/search_page.dart';
import 'package:artbooking/screens/settings_page.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/brightness.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class MainAppBar extends StatefulWidget {
  final bool renderSliver;

  const MainAppBar({
    Key? key,
    this.renderSliver = true,
  }) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    final isNarrow =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth;

    final padding = EdgeInsets.only(
      left: isNarrow ? 0.0 : 80.0,
    );

    if (widget.renderSliver) {
      return renderSliver(
        isNarrow: isNarrow,
        padding: padding,
      );
    }

    return renderBox(
      isNarrow: isNarrow,
      padding: padding,
    );
  }

  Widget addButton() {
    return IconButton(
      tooltip: "upload".tr(),
      onPressed: () {
        appUploadManager.pickImage(context);
      },
      icon: Icon(
        UniconsLine.plus,
        color: stateColors.foreground.withOpacity(0.6),
      ),
    );
  }

  Widget authenticatedMenu(bool isSmall) {
    return Container(
      padding: const EdgeInsets.only(
        top: 5.0,
        right: 10.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          addButton(),
          AvatarMenu(
            isSmall: isSmall,
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Switch from dark to light and vice-versa.
  Widget brightnessButton() {
    IconData iconBrightness = UniconsLine.brightness;
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = appStorage.getBrightness();

      iconBrightness = currentBrightness == Brightness.dark
          ? UniconsLine.adjust_half
          : UniconsLine.bright;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<String>(
        icon: Icon(
          iconBrightness,
          color: stateColors.foreground.withOpacity(0.6),
        ),
        tooltip: "brightness".tr(),
        onSelected: (value) {
          if (value == 'auto') {
            BrightnessUtils.setAutoBrightness(context);
            return;
          }

          final brightness =
              value == 'dark' ? Brightness.dark : Brightness.light;

          BrightnessUtils.setBrightness(context, brightness);
        },
        itemBuilder: (context) {
          final autoBrightness = appStorage.getAutoBrightness();
          final brightness = autoBrightness ? null : appStorage.getBrightness();

          final primary = stateColors.primary;
          final basic = stateColors.foreground;

          return [
            PopupMenuItem(
              value: 'auto',
              child: ListTile(
                leading: Icon(UniconsLine.brightness),
                title: Text(
                  "brightness_auto".tr(),
                  style: TextStyle(
                    color: autoBrightness ? primary : basic,
                  ),
                ),
                trailing: autoBrightness
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'dark',
              child: ListTile(
                leading: Icon(UniconsLine.adjust_half),
                title: Text(
                  "dark".tr(),
                  style: TextStyle(
                    color: brightness == Brightness.dark ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.dark
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'light',
              child: ListTile(
                leading: Icon(UniconsLine.bright),
                title: Text(
                  "light".tr(),
                  style: TextStyle(
                    color: brightness == Brightness.light ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.light
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget desktopSectionsRow() {
    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        sectionButton(
          onPressed: () => context.vRouter.push('/illustrations'),
          text: "illustrations".tr(),
        ),
        sectionButton(
          onPressed: () => context.vRouter.push('/books'),
          text: "books".tr(),
        ),
        sectionButton(
          onPressed: () => context.vRouter.push('/contests'),
          text: "contests".tr(),
        ),
        IconButton(
          onPressed: () {
            context.vRouter.push(SearchPage.route);
          },
          color: stateColors.foreground.withOpacity(0.8),
          icon: Icon(UniconsLine.search),
        ),
      ],
    );
  }

  Widget guestRow(bool isNarrow) {
    return Container(
      padding: const EdgeInsets.only(
        top: 5.0,
        right: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () => context.vRouter.push('/signin'),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("signin".tr()),
              ),
              style: TextButton.styleFrom(
                primary: stateColors.foreground,
                textStyle: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Text("signup".tr()),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              shape: RoundedRectangleBorder(),
              textStyle: FontsUtils.mainStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget langButton() {
    return LangPopupMenuButton(
      onLangChanged: (newLang) async {
        await context.setLocale(Locale(newLang));

        setState(() {
          stateUser.setLang(newLang);
        });
      },
      lang: stateUser.lang,
    );
  }

  Widget mobileSectionsRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: sectionsPopupMenu(),
        ),
        IconButton(
          tooltip: "search".tr(),
          onPressed: () {
            context.vRouter.push(SearchPage.route);
          },
          color: stateColors.foreground.withOpacity(0.8),
          icon: Icon(UniconsLine.search),
        ),
      ],
    );
  }

  Widget renderBox({
    bool isNarrow = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return AppBar(
      backgroundColor: stateColors.lightBackground,
      title: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppIcon(),
            sectionsRow(isNarrow),
            userSpace(isNarrow),
          ],
        ),
      ),
    );
  }

  Widget renderSliver({
    required bool isNarrow,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: stateColors.lightBackground,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppIcon(size: 32.0),
            sectionsRow(isNarrow),
            userSpace(isNarrow),
          ],
        ),
      ),
    );
  }

  Widget searchButton() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 8.0,
      ),
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          tooltip: "search".tr(),
          onPressed: () {
            context.vRouter.push(SearchPage.route);
          },
          color: stateColors.foreground,
          icon: Icon(UniconsLine.search),
        ),
      ),
    );
  }

  Widget sectionButton({
    VoidCallback? onPressed,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: UnderlinedButton(
        onTap: onPressed,
        child: Opacity(
          opacity: 0.8,
          child: Text(
            text.toUpperCase(),
            style: FontsUtils.mainStyle(
              color: stateColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionsPopupMenu() {
    return PopupMenuButton(
      child: Text(
        "sections".toUpperCase(),
        style: FontsUtils.mainStyle(
          color: Colors.black,
          fontSize: 18.0,
        ),
      ),
      itemBuilder: (context) => <PopupMenuItem<String>>[
        PopupMenuItem(
          value: IllustrationsPage.route,
          child: ListTile(
            leading: Icon(UniconsLine.image),
            title: Text("illustrations".tr()),
          ),
        ),
        PopupMenuItem(
          value: IllustrationsPage.route,
          child: ListTile(
            leading: Icon(UniconsLine.apps),
            title: Text("contests".tr()),
          ),
        ),
        PopupMenuItem(
          value: SettingsPage.route,
          child: ListTile(
            leading: Icon(UniconsLine.setting),
            title: Text("settings".tr()),
          ),
        ),
      ],
      onSelected: (String route) {
        context.vRouter.push(route);
        // if (pageRouteInfo.path != SettingsPageRoute().path) {
        //   context.router.root.push(pageRouteInfo);
        //   return;
        // }

        // if (stateUser.isUserConnected) {
        //   context.router.root.push(
        //     DashboardPageRoute(
        //       children: [DashSettingsRouter()],
        //     ),
        //   );

        //   return;
        // }

        // context.router.root.push(pageRouteInfo);
      },
    );
  }

  Widget sectionsRow(bool isNarrow) {
    if (isNarrow) {
      return mobileSectionsRow();
    }

    return desktopSectionsRow();
  }

  Widget userSpace(bool isNarrow) {
    if (stateUser.isUserConnected) {
      return authenticatedMenu(isNarrow);
    }

    return guestRow(isNarrow);
  }
}
