import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/screens/my_books_page.dart';
import 'package:artbooking/screens/my_illustrations_page.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

class MyActivityPage extends StatefulWidget {
  static String path = '/dashboard/activity';

  @override
  _MyActivityPageState createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> {
  final _scrollController = ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          MainAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              header(),
              body(),
              Padding(padding: const EdgeInsets.only(bottom: 200.0)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return Center(
        child: FullPageLoading(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        squareStatsRow(),
        textsStatsRow(),
      ],
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 60.0,
        bottom: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "activity".tr(),
            style: FontsUtils.title(),
          ),
        ],
      ),
    );
  }

  Widget squareStatsRow() {
    final stats = stateUser.userFirestore.stats!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 50.0,
        vertical: 60.0,
      ),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.start,
        children: <Widget>[
          squareStats(
            title: "illustrations".tr(),
            icon: Icon(
              UniconsLine.picture,
              size: 48.0,
            ),
            count: stats.illustrations!.owned,
            onTap: () => context.vRouter.push(MyIllustrationsPage.route),
          ),
          squareStats(
            title: "books".tr(),
            icon: Icon(
              UniconsLine.book_alt,
              size: 48.0,
            ),
            count: stats.books!.owned,
            onTap: () => context.vRouter.push(MyBooksPage.route),
          ),
          squareStats(
            title: "galleries".tr(),
            count: stats.galleries!.owned,
            onTap: () {},
          ),
          squareStats(
            title: "challenges".tr(),
            count: stats.challenges!.participating,
            onTap: () {},
          ),
          squareStats(
            title: "contests".tr(),
            count: stats.constests!.participating,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget squareStats({
    required String title,
    required int? count,
    required VoidCallback onTap,
    Widget? icon,
  }) {
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Text(
                        count.toString(),
                        style: FontsUtils.mainStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        title,
                        style: FontsUtils.mainStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (icon != null)
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    child: Opacity(
                      opacity: 0.6,
                      child: icon,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textsStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 50.0,
        vertical: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.storage),
            label: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: stateColors.foreground.withOpacity(0.6),
                  fontSize: 20.0,
                ),
                children: [
                  TextSpan(text: "space_total_used".tr()),
                  TextSpan(
                    text: "${getUsedSpace()}",
                    style: TextStyle(color: stateColors.primary),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.timelapse),
            label: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: stateColors.foreground.withOpacity(0.6),
                  fontSize: 20.0,
                ),
                children: [
                  TextSpan(text: "member_since".tr()),
                  TextSpan(
                    text:
                        '${Jiffy(stateUser.userFirestore.createdAt).format('MMMM yyyy')}',
                    style: TextStyle(color: stateColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SigninPage()),
          );
        });

        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  String getUsedSpace() {
    final usedBytes =
        stateUser.userFirestore.stats!.storage!.illustrations!.used!;
    var units = 'bytes';

    if (usedBytes < 1000) {
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000) {
      units = 'KB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000) {
      units = 'MB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000000) {
      units = 'GB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000000000) {
      units = 'TB';
      return '$usedBytes $units';
    }

    units = 'PB';
    return '$usedBytes $units';
  }
}
