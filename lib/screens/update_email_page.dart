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
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class UpdateEmailPage extends StatefulWidget {
  @override
  _UpdateEmailPageState createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  bool _isCheckingEmail = false;
  bool _isUpdating = false;
  bool _isCompleted = false;

  final _beginY = 10.0;
  final _passwordNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _emailInputValue = '';
  String _emailInputErrorMessage = '';
  String _passwordInputValue = '';

  Timer? _emailTimer;

  @override
  void dispose() {
    _passwordNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
    if (_isCompleted) {
      return completedView();
    }

    if (_isUpdating) {
      return updatingView();
    }

    return idleView();
  }

  Widget idleView() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            width: 400.0,
            child: Column(
              children: <Widget>[
                FadeInY(
                  delay: 0.milliseconds,
                  beginY: _beginY,
                  child: helperCard(),
                ),
                FadeInY(
                  delay: 100.milliseconds,
                  beginY: _beginY,
                  child: emailInput(),
                ),
                FadeInY(
                  delay: 200.milliseconds,
                  beginY: _beginY,
                  child: passwordInput(),
                ),
                FadeInY(
                  delay: 300.milliseconds,
                  beginY: _beginY,
                  child: validationButton(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 200.0),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
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
                  Icons.check,
                  size: 80.0,
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                child: Text(
                  "email_update_successful".tr(),
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
                          "email_update".tr(),
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
                            "email_update_description".tr(),
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
        bottom: 40.0,
      ),
      child: Card(
        color: stateColors.clairPink,
        elevation: 2.0,
        child: InkWell(
          child: Container(
            width: 330.0,
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
                            "email_current".tr(),
                          ),
                        ),
                        Text(
                          stateUser.email,
                          style: FontsUtils.mainStyle(
                            fontWeight: FontWeight.bold,
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

  Widget emailInput() {
    return Container(
      width: 390.0,
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: _emailController,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordNode.requestFocus(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              focusColor: stateColors.clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "email_new".tr(),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) async {
              _emailInputValue = value;

              setState(() {
                _isCheckingEmail = true;
              });

              final isWellFormatted =
                  UsersActions.checkEmailFormat(_emailInputValue);

              if (!isWellFormatted) {
                setState(() {
                  _isCheckingEmail = false;
                  _emailInputErrorMessage = "email_not_valid".tr();
                });

                return;
              }

              if (_emailTimer != null) {
                _emailTimer!.cancel();
                _emailTimer = null;
              }

              _emailTimer = Timer(1.seconds, () async {
                final isAvailable =
                    await (UsersActions.checkEmailAvailability(_emailInputValue)
                        as FutureOr<bool>);

                if (!isAvailable) {
                  setState(() {
                    _isCheckingEmail = false;
                    _emailInputErrorMessage = "email_not_available".tr();
                  });

                  return;
                }

                setState(() {
                  _isCheckingEmail = false;
                  _emailInputErrorMessage = '';
                });
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return "email_empty_forbidden".tr();
              }

              return null;
            },
          ),
          if (_isCheckingEmail) emailProgress(),
          if (_emailInputErrorMessage.isNotEmpty) emailInputError(),
        ],
      ),
    );
  }

  Widget emailInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(_emailInputErrorMessage,
          style: TextStyle(
            color: Colors.red.shade300,
          )),
    );
  }

  Widget emailProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: LinearProgressIndicator(),
    );
  }

  Widget passwordInput() {
    return Container(
      width: 390.0,
      padding: EdgeInsets.only(
        top: 20.0,
        bottom: 60.0,
        left: 30.0,
        right: 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: _passwordNode,
            controller: _passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              focusColor: stateColors.clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "password_current".tr(),
            ),
            obscureText: true,
            onChanged: (value) {
              _passwordInputValue = value;
            },
            onFieldSubmitted: (value) => updateEmailProcess(),
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
                  "email_updating".tr(),
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

  Widget validationButton() {
    return ElevatedButton(
      onPressed: updateEmailProcess,
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
                "email_update".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateEmailProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      if (!await (valuesAvailabilityCheck() as FutureOr<bool>)) {
        setState(() => _isUpdating = false);

        Snack.e(
          context: context,
          message: "email_not_available".tr(),
        );

        return;
      }

      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() => _isUpdating = false);
        context.vRouter.push(SigninPage.route);
        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email!,
        password: _passwordInputValue,
      );

      await userAuth.reauthenticateWithCredential(credentials);
      final idToken = await userAuth.getIdToken();

      final respUpdateEmail =
          await stateUser.updateEmail(_emailInputValue, idToken);

      if (!respUpdateEmail.success) {
        final exception = respUpdateEmail.error!;

        setState(() {
          _isUpdating = false;
        });

        Snack.e(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
        );

        return;
      }

      stateUser.clearAuthCache();

      setState(() {
        _isUpdating = false;
        _isCompleted = true;
      });
    } catch (error) {
      appLogger.e(error);

      setState(() {
        _isUpdating = false;
      });

      Snack.e(
        context: context,
        message: "email_update_error".tr(),
      );
    }
  }

  Future<bool?> valuesAvailabilityCheck() async {
    return await UsersActions.checkEmailAvailability(_emailInputValue);
  }

  bool inputValuesOk() {
    if (_emailInputValue.isEmpty) {
      Snack.e(
        context: context,
        message: "email_empty_forbidden".tr(),
      );

      return false;
    }

    if (_passwordInputValue.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(_emailInputValue)) {
      Snack.e(
        context: context,
        message: "email_not_validd".tr(),
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
            "email_current".tr(),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  stateUser.email,
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
