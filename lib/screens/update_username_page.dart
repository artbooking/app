import 'dart:async';

import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class UpdateUsernamePage extends StatefulWidget {
  @override
  _UpdateUsernamePageState createState() => _UpdateUsernamePageState();
}

class _UpdateUsernamePageState extends State<UpdateUsernamePage> {
  bool isCheckingAuth = false;
  bool isUpdating = false;
  bool isCheckingName = false;
  bool isCompleted = false;
  bool? isNameAvailable = false;

  final beginY = 10.0;
  final passwordNode = FocusNode();
  final usernameController = TextEditingController();
  final _pageScrollController = ScrollController();

  String currentUsername = '';
  String nameErrorMessage = '';
  String newUsername = '';

  Timer? nameTimer;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _pageScrollController,
        slivers: <Widget>[
          SliverEdgePadding(),
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
      return updatingView();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          width: 400.0,
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Icon(
                  Icons.check_circle_outline_outlined,
                  size: 80.0,
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                child: Text(
                  "username_update_success".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: context.vRouter.pop,
                child: Text("back".tr()),
              ),
            ],
          ),
        ),
      ]),
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
                          "username_update".tr(),
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
                            "username_update_description".tr(),
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

  Widget helperCard() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 80.0,
        bottom: 40.0,
      ),
      child: Card(
        color: stateColors.clairPink,
        elevation: 2.0,
        child: InkWell(
          child: Container(
            width: 340.0,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        UniconsLine.envelope,
                        color: stateColors.secondary,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: 0.6,
                          child: Text(
                            "username_current".tr(),
                            style: FontsUtils.mainStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          currentUsername,
                          style: FontsUtils.mainStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
          children: [
            FadeInY(
              beginY: 10.0,
              child: helperCard(),
            ),
            FadeInY(
              beginY: 10.0,
              delay: 100.milliseconds,
              child: usernameInput(),
            ),
            FadeInY(
              beginY: 10.0,
              delay: 200.milliseconds,
              child: validationButton(),
            ),
          ],
        ),
      ]),
    );
  }

  Widget updatingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          width: 400.0,
          child: Column(
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  "username_updating".tr(),
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget usernameInput() {
    return Container(
      width: 370.0,
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 80.0,
      ),
      child: Column(
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: usernameController,
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: stateColors.clairPink,
              labelText: "username_new".tr(),
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) async {
              setState(() {
                newUsername = value;
                isCheckingName = true;
              });

              final isWellFormatted =
                  UsersActions.checkUsernameFormat(newUsername);

              if (!isWellFormatted) {
                setState(() {
                  isCheckingName = false;
                  nameErrorMessage = newUsername.length < 3
                      ? "input_minimum_char".tr()
                      : "input_valid_format".tr();
                });

                return;
              }

              if (nameTimer != null) {
                nameTimer!.cancel();
                nameTimer = null;
              }

              nameTimer = Timer(1.seconds, () async {
                isNameAvailable =
                    await UsersActions.checkUsernameAvailability(newUsername);

                if (!isNameAvailable!) {
                  setState(() {
                    isCheckingName = false;
                    nameErrorMessage = "username_not_available".tr();
                  });

                  return;
                }

                setState(() {
                  isCheckingName = false;
                  nameErrorMessage = '';
                });
              });
            },
          ),
          if (isCheckingName)
            Container(
              width: 230.0,
              padding: const EdgeInsets.only(left: 40.0),
              child: LinearProgressIndicator(),
            ),
          if (nameErrorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 5.0),
              child: Text(
                nameErrorMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget validationButton() {
    return ElevatedButton(
      onPressed: updateUsernameProcess,
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
      ),
      child: SizedBox(
        width: 320.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "username_update".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = stateUser.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth == null) {
        return;
      }

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .get();

      final data = user.data();

      setState(() {
        currentUsername = data!['name'] ?? '';
      });
    } catch (error) {
      appLogger.e(error);
    }
  }

  bool inputValuesOk() {
    final isWellFormatted = UsersActions.checkUsernameFormat(newUsername);

    if (!isWellFormatted) {
      setState(() {
        isCheckingName = false;
        nameErrorMessage = newUsername.length < 3
            ? "input_minimum_char".tr()
            : "input_valid_format".tr();
      });

      return false;
    }

    return true;
  }

  void updateUsernameProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      isNameAvailable =
          await UsersActions.checkUsernameAvailability(newUsername);

      if (!isNameAvailable!) {
        setState(() {
          isCompleted = false;
          isUpdating = false;
        });

        Snack.e(
          context: context,
          message: "username_not_available_args".tr(args: [newUsername]),
        );

        return;
      }

      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() {
          isCompleted = false;
          isUpdating = false;
        });

        context.vRouter.push(SigninPage.route);
        return;
      }

      final usernameUpdateResp = await stateUser.updateUsername(newUsername);

      if (!usernameUpdateResp.success) {
        final exception = usernameUpdateResp.error!;

        setState(() {
          isCompleted = false;
          isUpdating = false;
        });

        Snack.e(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
        );

        return;
      }

      setState(() {
        isCompleted = true;
        isUpdating = false;
        currentUsername = newUsername;
        newUsername = '';
      });

      stateUser.setUsername(currentUsername);

      Snack.s(
        context: context,
        message: "username_update_success".tr(),
      );

      // Navigator.of(context).pop();
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isCompleted = false;
        isUpdating = false;
      });

      Snack.e(
        context: context,
        message: "username_update_error".tr(),
      );
    }
  }

  void showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: stateColors.clairPink,
          title: Text(
            "username_current".tr(),
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          children: <Widget>[
            Divider(
              color: stateColors.secondary,
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  currentUsername,
                  style: FontsUtils.mainStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "username_choose_description".tr(),
                  style: FontsUtils.mainStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
