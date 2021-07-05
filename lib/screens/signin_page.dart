import 'package:artbooking/actions/users.dart';

import 'package:artbooking/components/fade_in_x.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/loading_animation.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key, this.onSigninResult}) : super(key: key);

  static String route = '/signin';

  final void Function(bool isAuthenticated)? onSigninResult;

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  String email = '';
  String password = '';

  bool isCheckingAuth = false;
  bool isCompleted = false;
  bool isConnecting = false;

  final passwordNode = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          MainAppBar(),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 100.0,
              bottom: 300.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 320.0,
                      child: body(),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isConnecting) {
      return LoadingAnimation(
        textTitle: "signin_dot".tr(),
      );
    }

    return idleContainer();
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        passwordInput(),
        forgotPassword(),
        validationButton(),
        noAccountButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 80.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: "email".tr(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              onFieldSubmitted: (value) => passwordNode.requestFocus(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "email_empty_forbidden".tr();
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: TextButton(
        onPressed: () {
          context.vRouter.push('/forgotpassword');
        },
        child: Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "password_forgot".tr(),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (context.router.stack.length > 1)
          FadeInX(
            beginX: 10.0,
            delay: 200.milliseconds,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
              ),
              child: IconButton(
                onPressed: () => context.router.pop(),
                icon: Icon(Icons.arrow_back),
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FadeInY(
              beginY: 50.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "signin".tr(),
                  textAlign: TextAlign.center,
                  style: FontsUtils.mainStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 300.milliseconds,
              beginY: 50.0,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "signin_existing_account".tr(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget noAccountButton() {
    return FadeInY(
      delay: 400.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextButton(
            onPressed: () {
              context.vRouter.push('/signup');
            },
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "dont_own_account".tr(),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            )),
      ),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 30.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: passwordNode,
              controller: passwordController,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: 'Password',
              ),
              obscureText: true,
              onChanged: (value) {
                password = value;
              },
              onFieldSubmitted: (value) => signInProcess(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "password_empty_forbidden".tr();
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: ElevatedButton(
          onPressed: () => signInProcess(),
          style: ElevatedButton.styleFrom(
            primary: stateColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
          ),
          child: Container(
            width: 250.0,
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "signin".tr().toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Icon(
                    UniconsLine.arrow_right,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool inputValuesOk() {
    if (!UsersActions.checkEmailFormat(email)) {
      Snack.e(
        context: context,
        message: "email_not_valid".tr(),
      );

      return false;
    }

    if (password.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    return true;
  }

  void signInProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isConnecting = true;
    });

    try {
      final userCred = await stateUser.signin(
        email: email,
        password: password,
      );

      if (userCred == null) {
        appLogger.d("empty user");
        setState(() {
          isConnecting = false;
        });

        Snack.e(
          context: context,
          message: "account_doesnt_exist".tr(),
        );

        return;
      }

      appStorage.setCredentials(
        email: email,
        password: password,
      );

      isConnecting = false;
      isCompleted = true;

      // If this callback is defined,
      // this page is call from AuthGuard.
      if (widget.onSigninResult != null) {
        widget.onSigninResult!(true);
        return;
      }

      context.vRouter.push('/');
    } catch (error) {
      appLogger.d(error);

      Snack.e(
        context: context,
        message: "password_incorrect".tr(),
      );

      setState(() {
        isConnecting = false;
      });
    }
  }
}
