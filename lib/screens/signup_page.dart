import 'dart:async';

import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/fade_in_x.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/loading_animation.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class SignupPage extends StatefulWidget {
  final void Function(bool isAuthenticated)? onSignupResult;

  const SignupPage({Key? key, this.onSignupResult}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isCheckingEmail = false;
  bool _isCheckingName = false;
  bool _isSigningUp = false;

  final _confirmPasswordNode = FocusNode();
  final _passwordNode = FocusNode();
  final _usernameNode = FocusNode();

  String _confirmPassword = '';
  String _email = '';
  String _emailErrorMessage = '';
  String _nameErrorMessage = '';
  String _password = '';
  String _username = '';

  Timer? _emailTimer;
  Timer? _nameTimer;

  @override
  void dispose() {
    super.dispose();
    _usernameNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
                      width: 300.0,
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
    if (_isSigningUp) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          textTitle: "signup_dot".tr(),
        ),
      );
    }

    return idleContainer();
  }

  Widget emailInput() {
    return FadeInY(
      delay: 0.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 60.0),
        child: TextFormField(
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            icon: Icon(Icons.email),
            labelText: "email".tr(),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) async {
            _email = value;

            setState(() {
              _isCheckingEmail = true;
            });

            final isWellFormatted = UsersActions.checkEmailFormat(_email);

            if (!isWellFormatted) {
              setState(() {
                _isCheckingEmail = false;
                _emailErrorMessage = "email_not_valid".tr();
              });

              return;
            }

            if (_emailTimer != null) {
              _emailTimer!.cancel();
              _emailTimer = null;
            }

            _emailTimer = Timer(1.seconds, () async {
              final isAvailable =
                  await (UsersActions.checkEmailAvailability(_email)
                      as FutureOr<bool>);
              if (!isAvailable) {
                setState(() {
                  _isCheckingEmail = false;
                  _emailErrorMessage = "email_not_available".tr();
                });

                return;
              }

              setState(() {
                _isCheckingEmail = false;
                _emailErrorMessage = '';
              });
            });
          },
          onFieldSubmitted: (_) => _usernameNode.requestFocus(),
          validator: (value) {
            if (value!.isEmpty) {
              return "email_empty_forbidden".tr();
            }

            return null;
          },
        ),
      ),
    );
  }

  Widget emailInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(
        _emailErrorMessage,
        style: TextStyle(
          color: Colors.red.shade300,
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
            delay: 100.milliseconds,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
              ),
              child: IconButton(
                onPressed: context.router.pop,
                icon: Icon(UniconsLine.arrow_left),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeInY(
                beginY: 50.0,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "signup".tr(),
                    textAlign: TextAlign.center,
                    style: FontsUtils.mainStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              FadeInY(
                delay: 200.milliseconds,
                beginY: 50.0,
                child: Opacity(
                  opacity: 0.6,
                  child: Text("account_create_new".tr()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        if (_isCheckingEmail) emailProgress(),
        if (_emailErrorMessage.isNotEmpty) emailInputError(),
        nameInput(),
        if (_isCheckingName) nameProgress(),
        if (_nameErrorMessage.isNotEmpty) nameInputError(),
        passwordInput(),
        confirmPasswordInput(),
        validationButton(),
        alreadyHaveAccountButton(),
      ],
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

  Widget nameInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _usernameNode,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.person_outline,
                ),
                labelText: "username".tr(),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) async {
                setState(() {
                  _username = value;
                  _isCheckingName = true;
                });

                final isWellFormatted =
                    UsersActions.checkUsernameFormat(_username);

                if (!isWellFormatted) {
                  setState(() {
                    _isCheckingName = false;
                    _nameErrorMessage = _username.length < 3
                        ? "input_minimum_char".tr()
                        : "input_valid_format".tr();
                  });

                  return;
                }

                if (_nameTimer != null) {
                  _nameTimer!.cancel();
                  _nameTimer = null;
                }

                _nameTimer = Timer(1.seconds, () async {
                  final isAvailable =
                      await (UsersActions.checkUsernameAvailability(_username)
                          as FutureOr<bool>);

                  if (!isAvailable) {
                    setState(() {
                      _isCheckingName = false;
                      _nameErrorMessage = "name_unavailable".tr();
                    });

                    return;
                  }

                  setState(() {
                    _isCheckingName = false;
                    _nameErrorMessage = '';
                  });
                });
              },
              onFieldSubmitted: (_) => _passwordNode.requestFocus(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "name_empty_forbidden".tr();
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget nameInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(_nameErrorMessage,
          style: TextStyle(
            color: Colors.red.shade300,
          )),
    );
  }

  Widget nameProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: LinearProgressIndicator(),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _passwordNode,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: "password".tr(),
              ),
              obscureText: true,
              onChanged: (value) {
                if (value.length == 0) {
                  return;
                }
                _password = value;
              },
              onFieldSubmitted: (_) => _confirmPasswordNode.requestFocus(),
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

  Widget confirmPasswordInput() {
    return FadeInY(
      delay: 400.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _confirmPasswordNode,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: "password_confirm".tr(),
              ),
              obscureText: true,
              onChanged: (value) {
                if (value.length == 0) {
                  return;
                }
                _confirmPassword = value;
              },
              onFieldSubmitted: (value) => signUpProcess(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "password_confirm_empty_forbidden".tr();
                }

                if (_confirmPassword != _password) {
                  return "passwords_dont_match".tr();
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
      delay: 500.milliseconds,
      beginY: 50.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: ElevatedButton(
            onPressed: () => signUpProcess(),
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
                    "signup".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget alreadyHaveAccountButton() {
    return FadeInY(
      delay: 700.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ElevatedButton(
          onPressed: () {
            context.vRouter.push('/signin');
          },
          child: Opacity(
            opacity: 0.6,
            child: Text(
              "account_already_own".tr(),
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUpProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() => _isSigningUp = true);

    if (!await valuesAvailabilityCheck()) {
      setState(() {
        _isSigningUp = false;
      });

      Snack.e(
        context: context,
        message: "email_not_available".tr(),
      );

      return;
    }

    // ?NOTE: Triming because of TAB key on Desktop insert blank spaces.
    _email = _email.trim();
    _password = _password.trim();

    try {
      final respCreateAcc = await UsersActions.createAccount(
        email: _email,
        username: _username,
        password: _password,
      );

      if (!respCreateAcc.success) {
        final exception = respCreateAcc.error!;

        setState(() => _isSigningUp = false);

        Snack.e(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
        );

        return;
      }

      final userCred = await stateUser.signin(
        email: _email,
        password: _password,
      );

      setState(() => _isSigningUp = false);

      if (userCred == null) {
        Snack.e(
          context: context,
          message: "account_create_error".tr(),
        );

        return;
      }

      // PushNotifications.linkAuthUser(respCreateAcc.user.id);

      if (widget.onSignupResult != null) {
        widget.onSignupResult!(true);
        return;
      }

      context.vRouter.push('/');
    } catch (error) {
      appLogger.e(error);

      setState(() => _isSigningUp = false);

      Snack.e(
        context: context,
        message: "account_create_error".tr(),
      );
    }
  }

  Future<bool> valuesAvailabilityCheck() async {
    final isEmailOk =
        await (UsersActions.checkEmailAvailability(_email) as FutureOr<bool>);
    final isNameOk = await UsersActions.checkUsernameAvailability(_username);
    return isEmailOk && isNameOk!;
  }

  bool inputValuesOk() {
    if (_password.isEmpty || _confirmPassword.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    if (_confirmPassword != _password) {
      Snack.e(
        context: context,
        message: "passwords_dont_match".tr(),
      );

      return false;
    }

    if (_username.isEmpty) {
      Snack.e(
        context: context,
        message: "name_empty_forbidden".tr(),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(_email)) {
      Snack.e(
        context: context,
        message: "email_not_valid".tr(),
      );

      return false;
    }

    if (!UsersActions.checkUsernameFormat(_username)) {
      Snack.e(
        context: context,
        message: _username.length < 3
            ? "input_minimum_char".tr()
            : "input_valid_format".tr(),
      );

      return false;
    }

    return true;
  }
}
