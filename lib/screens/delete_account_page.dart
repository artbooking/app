import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/screens/home_page.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  DeleteAccountPageState createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends State<DeleteAccountPage> {
  bool isDeleting = false;
  bool isCompleted = false;

  double beginY = 10.0;

  String password = '';

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

    if (isDeleting) {
      return deletingView();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Icon(
                  UniconsLine.check,
                  color: Colors.green.shade300,
                  size: 80.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 30.0,
                ),
                child: Text(
                  "account_delete_successfull".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "see_you".tr(),
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 45.0,
                ),
                child: OutlinedButton(
                  onPressed: () => context.vRouter.push(HomePage.route),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text("back".tr()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget deletingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'Deleting your data...',
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
                        onPressed: context.router.pop,
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
                          "account_delete".tr(),
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
                            "account_delete_description".tr(),
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
    return Container(
      width: 350.0,
      padding: EdgeInsets.only(
        top: 60.0,
        bottom: 40.0,
      ),
      child: Card(
        color: stateColors.clairPink,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 16.0,
          ),
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: Icon(
                  UniconsLine.exclamation_triangle,
                  color: stateColors.secondary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "are_you_sure".tr(),
                      style: FontsUtils.mainStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          "action_irreversible".tr(),
                          style: FontsUtils.mainStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: showTipsDialog,
        ),
      ),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: <Widget>[
              FadeInY(
                delay: 0.milliseconds,
                beginY: beginY,
                child: helperCard(),
              ),
              FadeInY(
                delay: 100.milliseconds,
                beginY: beginY,
                child: passwordInput(),
              ),
              FadeInY(
                delay: 200.milliseconds,
                beginY: beginY,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: validationButton(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget imageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
      child: Image.asset(
        'assets/images/delete-user-light.png',
        width: 100.0,
      ),
    );
  }

  Widget passwordInput() {
    return SizedBox(
      width: 340.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: stateColors.clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "password_enter".tr(),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            onFieldSubmitted: (value) => deleteAccountProcess(),
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

  Widget validationButton() {
    return ElevatedButton(
      onPressed: deleteAccountProcess,
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
      ),
      child: SizedBox(
        width: 324.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "account_delete".tr().toUpperCase(),
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

  void deleteAccountProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() => isDeleting = true);

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() => isDeleting = false);
        context.vRouter.push(SigninPage.route);
        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email!,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);
      final idToken = await userAuth.getIdToken();

      final respDelAcc = await stateUser.deleteAccount(idToken);

      if (!respDelAcc.success) {
        final exception = respDelAcc.error!;

        setState(() {
          isDeleting = false;
        });

        Snack.e(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
        );

        return;
      }

      await stateUser.signOut();
      stateUser.setUsername('');
      appStorage.clearUserAuthData();

      // PushNotifications.unlinkAuthUser();

      setState(() {
        isDeleting = false;
        isCompleted = true;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isDeleting = false;
      });

      Snack.e(
        context: context,
        message: (error as PlatformException).message,
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

    return true;
  }

  void showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: stateColors.clairPink,
          title: Text(
            "account_deletion_after".tr(),
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
                  Text("account_deletion_point_1".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("account_deletion_point_2".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("account_deletion_point_3".tr()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
