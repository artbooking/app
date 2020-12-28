import 'dart:ui';

import 'package:artbooking/components/sliver_appbar_header.dart';
import 'package:artbooking/screens/dashboard.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDesktop extends StatefulWidget {
  @override
  _HomeDesktopState createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppHeader(
            showBackButton: false,
          ),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 120.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              Text(
                "ArtBooking",
                style: GoogleFonts.yellowtail(
                  fontSize: 120.0,
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "Your personal inspirations",
                  style: TextStyle(
                    fontSize: 26.0,
                  ),
                  // style: GoogleFonts.amaticSc(
                  //   fontSize: 30.0,
                  // ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );

    // return Container(
    //   height: MediaQuery.of(context).size.height,
    //   child: Row(
    //     children: <Widget>[
    //       heroIllustration(),
    //       textIllustration(),
    //     ],
    //   ),
    // );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              'Art Booking',
              style: GoogleFonts.amaticSc(
                color: stateColors.primary,
                fontSize: 30.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child:
                stateUser.isUserConnected ? dashboardButton() : signinButton(),
          ),
        ],
      ),
    );
  }

  Widget dashboardButton() {
    return Material(
      elevation: 1.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: Ink.image(
        image: NetworkImage(
            'https://drawinghowtos.com/wp-content/uploads/2019/04/fox-colored.png'),
        fit: BoxFit.cover,
        width: 60.0,
        height: 60.0,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => Dashboard()),
            );
          },
        ),
      ),
    );
  }

  Widget signinButton() {
    return RaisedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Signin()),
        );
      },
      color: stateColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Sign in',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget heroText() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                // padding: const EdgeInsets.all(25.0),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    'Art Booking',
                    style: GoogleFonts.amaticSc(
                      color: Colors.green.shade300,
                      fontSize: 30.0,
                    ),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => Signin()),
                  );
                },
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textIllustration() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Illustration title',
            style: GoogleFonts.amaticSc(
              fontSize: 60.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: Opacity(
              opacity: .6,
              child: Text(
                "Lore: It was a night of full moon. No sound around...",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget heroIllustration() {
    return Expanded(
      child: Material(
        elevation: 4.0,
        color: Colors.transparent,
        child: Ink.image(
          image: NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/art%2Fjeremie_corpinot%2FFlorale%2Fflorale_0_1080.png?alt=media&token=cd3a1f4d-f935-4cc7-b118-a9e6dca3de65'),
          fit: BoxFit.cover,
          // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn),
          height: MediaQuery.of(context).size.height,
          child: InkWell(
            onTap: () {},
            onHover: (hit) {},
          ),
        ),
      ),
    );
  }
}
