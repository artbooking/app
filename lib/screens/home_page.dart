import 'package:artbooking/components/footer.dart';
import 'package:artbooking/components/landing_contact.dart';
import 'package:artbooking/components/landing_curated.dart';
import 'package:artbooking/components/landing_hero.dart';
import 'package:artbooking/components/landing_quote.dart';
import 'package:artbooking/components/landing_roadmap.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/state/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class HomePage extends StatefulWidget {
  static String route = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  bool _isFabVisible = false;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floattingActionButton(),
      body: Overlay(
        initialEntries: [
          OverlayEntry(builder: (context) {
            return NotificationListener<ScrollNotification>(
              onNotification: onNotification,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverEdgePadding(
                    padding: const EdgeInsets.only(top: 30.0),
                  ),
                  MainAppBar(),
                  SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      LandingHero(),
                      LandingCurated(),
                      LandingQuote(),
                      LandingRoadmap(),
                      LandingContact(),
                      Footer(pageScrollController: _scrollController),
                    ]),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget floattingActionButton() {
    if (!_isFabVisible) {
      return Container();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: 500.milliseconds,
          curve: Curves.bounceIn,
        );
      },
      backgroundColor: stateColors.secondary,
      label: Text("scroll_to_top".tr()),
    );
  }

  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }

    return false;
  }
}
