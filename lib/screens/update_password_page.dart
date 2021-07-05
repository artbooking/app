import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  bool isCompleted = false;
  bool isUpdating = false;

  double beginY = 10.0;

  final newPasswordNode = FocusNode();

  String password = '';
  String newPassword = '';

  @override
  void dispose() {
    newPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          MainAppBar(),
          header(),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedView();
    }

    if (isUpdating) {
      return updatingScreen();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Icon(
                  UniconsLine.check,
                  color: stateColors.validation,
                  size: 80.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
                child: Text(
                  "password_update_success".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget currentPasswordInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      width: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: stateColors.clairPink,
              labelText: "password_current".tr(),
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
            onChanged: (value) {
              password = value;
            },
            onFieldSubmitted: (_) => newPasswordNode.requestFocus(),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return "password_empty_forbidden".tr();
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget header() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: IconButton(
                        onPressed: context.vRouter.pop,
                        icon: Icon(UniconsLine.arrow_left),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.4,
                        child: Text(
                          "settings".tr().toUpperCase(),
                          style: FontsUtils.mainStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "password_update".tr(),
                          style: FontsUtils.mainStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 400.0,
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            "password_update_description".tr(),
                            style: FontsUtils.mainStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget helpCard() {
    return Container(
      padding: EdgeInsets.only(
        left: 25.0,
        right: 25.0,
        top: 80.0,
        bottom: 40.0,
      ),
      width: 378.0,
      child: Card(
        color: stateColors.clairPink,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Icon(UniconsLine.question),
          title: Opacity(
            opacity: 0.6,
            child: Text(
              "password_choosing_good".tr(),
              style: FontsUtils.mainStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Text(
            "password_choosing_good_desc".tr(),
            style: FontsUtils.mainStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: showTipsDialog,
        ),
      ),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Column(
          children: <Widget>[
            FadeInY(
              delay: 0.milliseconds,
              beginY: beginY,
              child: helpCard(),
            ),
            FadeInY(
              delay: 100.milliseconds,
              beginY: beginY,
              child: currentPasswordInput(),
            ),
            FadeInY(
              delay: 200.milliseconds,
              beginY: beginY,
              child: newPasswordInput(),
            ),
            FadeInY(
              delay: 300.milliseconds,
              beginY: beginY,
              child: validationButton(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 200.0),
            ),
          ],
        ),
      ]),
    );
  }

  Widget newPasswordInput() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 60.0,
        left: 40.0,
        right: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: newPasswordNode,
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: stateColors.clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "password_new".tr(),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.0,
                ),
              ),
            ),
            obscureText: true,
            onChanged: (value) {
              newPassword = value;
            },
            onFieldSubmitted: (value) => updatePassword(),
            validator: (value) {
              if (value!.isEmpty) {
                return "password_empty_forbidden".tr();
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget textTitle() {
    return Text(
      "password_update".tr(),
      style: TextStyle(
        fontSize: 35.0,
      ),
    );
  }

  Widget updatingScreen() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedAppIcon(),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                "password_updating".tr(),
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ],
        ),
      ),
    ]));
  }

  Widget validationButton() {
    return ElevatedButton(
      onPressed: updatePassword,
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
      ),
      child: SizedBox(
        width: 300.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "password_update".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(UniconsLine.check),
          ],
        ),
      ),
    );
  }

  void updatePassword() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() => isUpdating = true);

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() => isUpdating = false);
        context.vRouter.push(SigninPage.route);
        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email!,
        password: password,
      );

      final authResult =
          await userAuth.reauthenticateWithCredential(credentials);

      await authResult.user!.updatePassword(newPassword);
      appStorage.setPassword(newPassword);

      setState(() {
        isUpdating = false;
        isCompleted = true;
      });
    } catch (error) {
      appLogger.e(error);
      setState(() => isUpdating = false);

      Snack.e(
        context: context,
        message: "password_update_error".tr(),
      );
    }
  }

  bool inputValuesOk() {
    if (password.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    if (newPassword.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    return true;
  }

  void showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: stateColors.clairPink,
          title: Text(
            "password_tips".tr(),
            style: FontsUtils.mainStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: <Widget>[
            Divider(
              color: stateColors.secondary,
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("password_tips_1".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("password_tips_2".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("password_tips_3".tr()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
