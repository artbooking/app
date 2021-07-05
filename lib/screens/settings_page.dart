import 'dart:async';

import 'package:artbooking/components/better_avatar.dart';
import 'package:artbooking/components/fade_in_x.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/page_title.dart';
import 'package:artbooking/router/app_router_nav_args.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/user/user_pp.dart';
import 'package:artbooking/types/user/user_pp_path.dart';
import 'package:artbooking/types/user/user_pp_url.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/brightness.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/language.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime_type/mime_type.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  static String route = '/dashboard/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoadingLang = false;
  bool isLoadingAvatarUrl = false;
  bool isNameAvailable = false;
  bool isThemeAuto = true;
  bool notificationsON = false;
  bool _isUpdating = false;

  Brightness? brightness;
  Brightness? currentBrightness;

  double beginY = 20.0;

  String avatarUrl = '';
  String imageUrl = '';
  String notifLang = 'en';
  String selectedLang = 'English';

  Timer? nameTimer;
  Timer? quotidiansNotifTimer;

  ScrollController _pageScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    initBrightness();

    setState(() {
      selectedLang = Language.frontend(stateUser.lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _pageScrollController,
              slivers: <Widget>[
                MainAppBar(),
                body(),
              ],
            ),
            popupProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget accountSettings() {
    return Observer(
      builder: (_) {
        final isUserConnected = stateUser.isUserConnected;

        if (isUserConnected) {
          return Column(
            children: [
              avatar(),
              accountActions(isUserConnected),
              updateUsernameButton(isUserConnected),
              emailButton(),
              // Divider(thickness: 1.0, height: 80.0),
            ],
          );
        }

        return Container();
      },
    );
  }

  Widget accountActions(bool isUserConnected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Wrap(
        spacing: 15.0,
        children: <Widget>[
          FadeInX(
            delay: 0.milliseconds,
            beginX: 50.0,
            child: updatePasswordButton(),
          ),
          FadeInX(
            delay: 100.milliseconds,
            beginX: 50.0,
            child: deleteAccountButton(),
          )
        ],
      ),
    );
  }

  Widget appSettings() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          themeSwitcher(),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 100.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget avatar() {
    return Observer(builder: (context) {
      final String avatarUrl = getAvatarUrl();

      return Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 42.0,
                right: 8.0,
              ),
              child: BetterAvatar(
                size: 160.0,
                image: NetworkImage(avatarUrl),
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                onTap: () {
                  if (stateUser.userFirestore.pp!.url!.edited!.isEmpty) {
                    return;
                  }

                  AppRouterNavArgs.lastEditImageSelected =
                      ExtendedNetworkImageProvider(
                    stateUser.userFirestore.pp!.url!.original!,
                    cache: true,
                    cacheRawData: true,
                  );

                  context.vRouter.push('edit/pp');

                  // context.router.root.push(
                  //   DashboardPageRoute(children: [
                  //     DashProfileRouter(
                  //       children: [
                  //         EditImagePageRoute(
                  //           image: ExtendedNetworkImageProvider(
                  //             stateUser.userFirestore.pp!.url!.original!,
                  //             cache: true,
                  //             cacheRawData: true,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ]),
                  // );
                },
              ),
            ),
            Opacity(
              opacity: 0.6,
              child: IconButton(
                tooltip: "pp_upload".tr(),
                onPressed: uploadPicture,
                icon: Icon(UniconsLine.upload),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget body() {
    double paddingTop = 60.0;
    bool showBigTitle = false;

    if (MediaQuery.of(context).size.width > Constants.maxMobileWidth) {
      paddingTop = 20.0;
      showBigTitle = true;
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: paddingTop,
        bottom: 300.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (showBigTitle) header(),
          accountSettings(),
          // appSettings(),
        ]),
      ),
    );
  }

  Widget deleteAccountButton() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          width: 90.0,
          height: 90.0,
          child: Card(
            elevation: 4.0,
            child: InkWell(
              onTap: () => context.vRouter.push('delete/account'),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Icon(UniconsLine.trash),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 80.0,
          child: Opacity(
            opacity: 0.8,
            child: Text(
              "account_delete".tr(),
              textAlign: TextAlign.center,
              style: FontsUtils.mainStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: PageTitle(
        textTitle: "settings".tr(),
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget emailButton() {
    return TextButton(
      onPressed: () async {
        context.vRouter.push('update/email');
      },
      style: TextButton.styleFrom(
        primary: Colors.black,
      ),
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text(
                  "email".tr(),
                  style: FontsUtils.mainStyle(
                    fontSize: 14.0,
                  ),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                    ),
                    child: Text(
                      stateUser.email,
                      style: TextStyle(
                        color: stateColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            });
      },
      child: Container(
        width: 250.0,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(UniconsLine.envelope),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.3,
                        child: Text(
                          "email".tr().toUpperCase(),
                          style: FontsUtils.mainStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        stateUser.email,
                        style: FontsUtils.mainStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget updateUsernameButton(bool isUserConnected) {
    return TextButton(
      onPressed: () {
        context.vRouter.push('update/username');
      },
      style: TextButton.styleFrom(
        primary: Colors.black,
      ),
      child: Container(
        width: 250.0,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(UniconsLine.user),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.3,
                        child: Text(
                          "username".tr().toUpperCase(),
                          style: FontsUtils.mainStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        stateUser.username!,
                        style: FontsUtils.mainStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget langSelect() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: ListTile(
        leading: Icon(Icons.language),
        subtitle: Text("language_app_select".tr()),
        title: DropdownButton<String>(
          elevation: 3,
          value: selectedLang,
          isDense: true,
          icon: Container(),
          underline: Container(),
          style: TextStyle(
            color: stateColors.foreground,
            fontFamily: GoogleFonts.raleway().fontFamily,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (String? newValue) {
            setState(() {
              selectedLang = newValue ?? '';
            });

            updateLang();
          },
          items: ['English', 'Français'].map((String value) {
            return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                ));
          }).toList(),
        ),
      ),
    );
  }

  Widget popupProgressIndicator() {
    if (!_isUpdating) {
      return Container();
    }

    return Positioned(
      top: 100.0,
      right: 24.0,
      child: SizedBox(
        width: 240.0,
        child: Card(
          elevation: 4.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 4.0,
                child: LinearProgressIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      UniconsLine.circle,
                      color: stateColors.secondary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "user_updating".tr(),
                            style: FontsUtils.mainStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget themeSwitcher() {
    return Container(
      width: 400.0,
      padding: EdgeInsets.only(
        bottom: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FadeInY(
            delay: 0.milliseconds,
            beginY: 10.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "theme".tr(),
                    style: FontsUtils.mainStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: stateColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInY(
            delay: 100.milliseconds,
            beginY: 10.0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  themeDescription(),
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 200.milliseconds,
            beginY: 10.0,
            child: SwitchListTile(
              title: Text("theme_automatic".tr()),
              secondary: const Icon(Icons.autorenew),
              value: isThemeAuto,
              onChanged: (newValue) {
                setState(() => isThemeAuto = newValue);

                if (newValue) {
                  BrightnessUtils.setAutoBrightness(context);
                  return;
                }

                currentBrightness = appStorage.getBrightness();
                BrightnessUtils.setBrightness(context, currentBrightness);
              },
            ),
          ),
          if (!isThemeAuto)
            FadeInY(
              delay: 0.milliseconds,
              beginY: 10.0,
              child: SwitchListTile(
                title: Text("light".tr()),
                secondary: const Icon(Icons.lightbulb_outline),
                value: currentBrightness == Brightness.light,
                onChanged: (newValue) {
                  currentBrightness =
                      newValue ? Brightness.light : Brightness.dark;

                  BrightnessUtils.setBrightness(context, currentBrightness);
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget updatePasswordButton() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          width: 90.0,
          height: 90.0,
          child: Card(
            elevation: 4.0,
            child: InkWell(
              onTap: () {
                context.vRouter.push('update/password');
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Icon(UniconsLine.shield),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 80.0,
          child: Opacity(
            opacity: 0.8,
            child: Text(
              "password_update".tr(),
              textAlign: TextAlign.center,
              style: FontsUtils.mainStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getAvatarUrl() {
    String? avatarUrl = stateUser.userFirestore.pp!.url!.edited;

    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = stateUser.userFirestore.pp!.url!.original;
    }

    if (avatarUrl!.isEmpty) {
      avatarUrl = "https://img.icons8.com/plasticine/100/000000/flower.png";
    }

    return avatarUrl;
  }

  void initBrightness() {
    final autoBrightness = appStorage.getAutoBrightness();
    isThemeAuto = autoBrightness;

    if (!autoBrightness) {
      currentBrightness = appStorage.getBrightness();
    } else {
      Brightness brightness = Brightness.light;
      final now = DateTime.now();

      if (now.hour < 6 || now.hour > 17) {
        brightness = Brightness.dark;
      }

      currentBrightness = brightness;
    }
  }

  String themeDescription() {
    return isThemeAuto
        ? "theme_auto_description".tr()
        : "theme_manual_description".tr();
  }

  void updateImageUrl({String? imageName}) async {
    setState(() => isLoadingAvatarUrl = true);

    try {
      final userAuth = stateUser.userAuth!;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .update({
        'urls.image': 'local:$imageName',
      });

      setState(() {
        avatarUrl = 'local:$imageName';
        isLoadingAvatarUrl = false;
      });

      Snack.s(
        context: context,
        message: "profile_update_success".tr(),
      );
    } catch (error) {
      appLogger.e(error);

      setState(() => isLoadingAvatarUrl = false);

      Snack.e(
        context: context,
        message: "profile_update_error".tr(),
      );
    }
  }

  void updateLang() async {
    setState(() {
      isLoadingLang = true;
    });

    final lang = Language.backend(selectedLang);

    Language.setLang(lang);

    setState(() {
      isLoadingLang = false;
    });

    Snack.s(
      context: context,
      message: "language_update_success".tr(),
    );
  }

  void updateUser() async {
    setState(() => _isUpdating = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      await Cloud.fun('users-updateUser').call({
        'userId': uid,
        'updatePayload': stateUser.userFirestore.toJSON(),
      });

      setState(() => _isUpdating = false);
    } catch (error) {
      setState(() => _isUpdating = false);
      appLogger.e(error);
    }
  }

  void uploadPicture() async {
    FilePickerCross choosenFile = await FilePickerCross.importFromStorage(
      type: FileTypeCross.image,
      fileExtension: 'jpg,jpeg,png,gif',
    );

    if (choosenFile.length >= 5 * 1024 * 1024) {
      Snack.e(
        context: context,
        message: "image_size_exceeded".tr(),
      );

      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("user_not_connected".tr());
    }

    setState(() => _isUpdating = true);

    final ext =
        choosenFile.fileName!.substring(choosenFile.fileName!.lastIndexOf('.'));

    final metadata = SettableMetadata(
      contentType: mime(choosenFile.fileName),
      customMetadata: {
        'extension': ext,
        'userId': user.uid,
      },
    );

    try {
      final response = await Cloud.fun('users-clearProfilePicture').call();
      final bool success = response.data['success'];

      if (!success) {
        throw "Error while calling cloud function.";
      }

      final imagePath = "images/users/${user.uid}/pp/original$ext";

      final task = FirebaseStorage.instance
          .ref(imagePath)
          .putData(choosenFile.toUint8List(), metadata);

      final snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        stateUser.userFirestore.urls!.setUrl('image', downloadUrl);
        stateUser.userFirestore.pp!.update(
          UserPP(
            ext: ext.replaceFirst('.', ''),
            size: choosenFile.length,
            updatedAt: DateTime.now(),
            path: UserPPPath(original: imagePath),
            url: UserPPUrl(original: downloadUrl),
          ),
        );

        _isUpdating = false;
      });

      updateUser();
    } catch (error) {
      appLogger.e(error);
      setState(() => _isUpdating = false);
    }
  }
}
