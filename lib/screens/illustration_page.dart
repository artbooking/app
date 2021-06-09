import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/author_header.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/illustration_poster.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class IllustrationPage extends StatefulWidget {
  final String illustrationId;
  final Illustration illustration;

  const IllustrationPage({
    Key key,
    @PathParam() this.illustrationId,
    this.illustration,
  }) : super(key: key);

  @override
  _IllustrationPageState createState() => _IllustrationPageState();
}

class _IllustrationPageState extends State<IllustrationPage> {
  /// True if data is being loaded.
  bool _isLoading = false;

  Illustration _illustration;

  String _newName = '';
  String _newDesc = '';
  String _newSummary = '';

  bool _isEditModeOn = false;

  TextEditingController _nameController;
  TextEditingController _descController;
  TextEditingController _summaryController;

  IllustrationLicense _newLicense = IllustrationLicense();
  ContentVisibility _newVisibility = ContentVisibility.private;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _descController = TextEditingController();
    _summaryController = TextEditingController();

    if (widget.illustration != null) {
      _illustration = widget.illustration;
    } else {
      fetchIllustration();
    }
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _descController?.dispose();
    _summaryController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener(
            child: CustomScrollView(
              slivers: [
                SliverEdgePadding(),
                MainAppBar(),
                body(),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    bottom: 120.0,
                  ),
                ),
              ],
            ),
          ),
          saveChangesPanel(),
        ],
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return loadingView();
    }

    return idleView();
  }

  Widget dates() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            Jiffy(_illustration.createdAt).fromNow(),
            style: FontsUtils.mainStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget header() {
    return Row(
      children: [
        IconButton(
          color: stateColors.primary,
          onPressed: context.router.pop,
          icon: Icon(UniconsLine.arrow_left),
        ),
        Expanded(
          child: Opacity(
            opacity: 0.8,
            child: Text(
              _illustration.name ?? '',
              style: FontsUtils.mainStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget idleView() {
    return SliverPadding(
      padding: const EdgeInsets.all(60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          header(),
          illustrationCard(),
          dates(),
          actionsRow(),
          if (_isEditModeOn) metdataEdit() else metadata(),
        ]),
      ),
    );
  }

  Widget illustrationCard() {
    final size = MediaQuery.of(context).size;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width - 200.0,
          maxHeight: size.height,
        ),
        child: IllustrationPoster(
          illustration: _illustration,
        ),
      ),
    );
  }

  Widget loadingView() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 80.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                AnimatedAppIcon(
                  textTitle: "Loading...",
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget description() {
    if (_illustration.description == null ||
        _illustration.description.isEmpty) {
      return Container();
    }

    return Container(
      width: 400.0,
      child: Opacity(
        opacity: 0.4,
        child: Text(
          _illustration.description ?? '',
          style: FontsUtils.mainStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget summary() {
    if (_illustration.story == null || _illustration.story.isEmpty) {
      return Container();
    }

    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(top: 12.0),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          _illustration.story ?? '',
          style: FontsUtils.mainStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }

  Widget metadata() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60.0,
      ),
      child: Column(
        children: [
          AuthorHeader(
            authorId: _illustration.author.id,
            padding: const EdgeInsets.only(bottom: 60.0),
          ),
          description(),
          summary(),
        ],
      ),
    );
  }

  Widget metdataEdit() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 250.0,
            child: TextField(
              autofocus: true,
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Name",
              ),
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                _newName = newValue;
              },
            ),
          ),
          Container(
            width: 250.0,
            padding: const EdgeInsets.only(top: 12.0),
            child: TextField(
              controller: _descController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description",
              ),
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                _newDesc = newValue;
              },
            ),
          ),
          Container(
            width: 500.0,
            padding: const EdgeInsets.only(top: 24.0),
            child: TextField(
              controller: _summaryController,
              decoration: InputDecoration(
                labelText: "Summary",
              ),
              maxLines: null,
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                _newSummary = newValue;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget saveChangesPanel() {
    if (!_isEditModeOn) {
      return Container();
    }

    return Positioned(
      left: 0.0,
      bottom: 0.0,
      right: 0.0,
      height: 80.0,
      child: FadeInY(
        beginY: 12.0,
        child: Material(
          elevation: 4.0,
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Save these information?",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 12.0,
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditModeOn = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 60.0,
                        ),
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditModeOn = false;
                    });

                    saveNewMetadata();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 60.0,
                      ),
                      child: Text(
                        "Save",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actionsRow() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 12.0,
        right: 12.0,
      ),
      child: Opacity(
        opacity: 0.8,
        child: Wrap(
          spacing: 16.0,
          alignment: WrapAlignment.center,
          children: [
            IconButton(
              tooltip: "like".tr(),
              icon: Icon(UniconsLine.heart),
              onPressed: () {},
            ),
            IconButton(
              tooltip: "share".tr(),
              icon: Icon(UniconsLine.share),
              onPressed: () {},
            ),
            IconButton(
              tooltip: "edit".tr(),
              icon: Icon(UniconsLine.edit),
              onPressed: () {
                setState(() {
                  _nameController.text = _illustration.name;
                  _descController.text = _illustration.description;
                  _summaryController.text = _illustration.story;

                  _newName = _illustration.name;
                  _newDesc = _illustration.description;
                  _newSummary = _illustration.story;
                  _newLicense = _illustration.license;
                  _newVisibility = _illustration.visibility;

                  _isEditModeOn = !_isEditModeOn;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void fetchIllustration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final illusSnap = await FirebaseFirestore.instance
          .collection('illustrations')
          .doc(widget.illustrationId)
          .get();

      final illusData = illusSnap.data();

      if (!illusSnap.exists || illusData == null) {
        Snack.e(
          context: context,
          message: "The illustration with the id "
              "${widget.illustrationId} doesn't exist.",
        );

        return;
      }

      illusData['id'] = illusSnap.id;

      setState(() {
        _illustration = Illustration.fromJSON(illusData);
        _isLoading = false;
      });
    } catch (error) {
      appLogger.e(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void saveNewMetadata() async {
    setState(() {
      _illustration.name = _newName;
      _illustration.description = _newDesc;
      _illustration.story = _newSummary;
      _illustration.license = _newLicense;
      _illustration.visibility = _newVisibility;
    });

    final result = await IllustrationsActions.updateMetadata(
      name: _newName,
      description: _newDesc,
      summary: _newSummary,
      license: _newLicense,
      visibility: _newVisibility,
      illustration: _illustration,
    );

    if (!result.success) {
      Snack.e(
        context: context,
        message: "Sorry, there was an error while saving your changes."
            " Try again later or contact us.",
      );

      fetchIllustration();
    }
  }
}
