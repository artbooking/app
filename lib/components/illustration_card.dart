import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A component representing an illustration with its main content (an image).
class IllustrationCard extends StatefulWidget {
  /// A component representing an illustration with its main content (an image).
  IllustrationCard({
    this.index = 0,
    required this.illustration,
    this.selected = false,
    this.selectionMode = false,
    this.onLongPress,
    this.size = 300.0,
    this.onTap,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
  });

  /// Index position in a list, if available.
  final int index;

  /// If true, the card will be marked with a check circle.
  final bool selected;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selectionMode;

  /// Illustration's data for this card.
  final Illustration illustration;

  /// Trigger when the user long press this card.
  final Function(bool)? onLongPress;

  /// Card's size (width = height).
  final double size;

  /// Trigger when the user taps on this card.
  final VoidCallback? onTap;

  /// Popup menu item entries.
  final List<PopupMenuEntry<IllustrationItemAction>> popupMenuEntries;

  /// Callback function when popup menu item entries are tapped.
  final void Function(IllustrationItemAction, int, Illustration)?
      onPopupMenuItemSelected;

  @override
  _IllustrationCardState createState() => _IllustrationCardState();
}

class _IllustrationCardState extends State<IllustrationCard>
    with AnimationMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  bool _showPopupMenu = false;

  double _startElevation = 3.0;
  double _endElevation = 6.0;
  double _elevation = 4.0;

  @override
  void initState() {
    super.initState();

    _scaleController = createController()..duration = 250.milliseconds;
    _scaleAnimation =
        0.6.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);

    setState(() {
      _elevation = _startElevation;
    });

    checkProperties();
  }

  @override
  Widget build(BuildContext context) {
    final illustration = widget.illustration;
    Widget child = imageCard();

    if (illustration.getThumbnail().isEmpty) {
      child = loadingCard();
    }

    return Hero(
      tag: illustration.id,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: child,
        ),
      ),
    );
  }

  Widget imageCard() {
    String imageUrl = widget.illustration.getThumbnail();
    Color defaultColor = Colors.transparent;

    return Card(
      color: widget.selected ? stateColors.primary : defaultColor,
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink.image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: () {
            if (widget.onLongPress != null) {
              widget.onLongPress!(widget.selected);
            }
          },
          onHover: (isHover) {
            if (isHover) {
              setState(() {
                _elevation = _endElevation;
                _showPopupMenu = true;
                _scaleController.forward();
              });

              return;
            }

            setState(() {
              _elevation = _startElevation;
              _showPopupMenu = false;
              _scaleController.reverse();
            });
          },
          child: Stack(
            children: [
              multiSelectButton(),
              Positioned(
                bottom: 10.0,
                right: 10.0,
                child: popupMenuButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingCard() {
    return Card(
      color: stateColors.clairPink,
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer(
        colorOpacity: 0.2,
        color: stateColors.primary,
        child: Container(),
      ),
    );
  }

  Widget multiSelectButton() {
    if (!widget.selectionMode) {
      return Container();
    }

    if (!widget.selected) {
      return Positioned(
        top: 10.0,
        right: 10.0,
        child: Material(
          elevation: 2.0,
          color: Colors.white,
          clipBehavior: Clip.hardEdge,
          shape: CircleBorder(),
          child: Icon(
            UniconsLine.circle,
            color: stateColors.primary,
          ),
        ),
      );
    }

    return Positioned(
      top: 10.0,
      right: 10.0,
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        clipBehavior: Clip.hardEdge,
        shape: CircleBorder(),
        child: Icon(
          UniconsLine.check_circle,
          color: stateColors.primary,
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    return Opacity(
      opacity: _showPopupMenu ? 1.0 : 0.0,
      child: PopupMenuButton<IllustrationItemAction>(
        icon: MirrorAnimation<Color?>(
          tween: stateColors.primary.tweenTo(stateColors.secondary),
          duration: 2.seconds,
          curve: Curves.decelerate,
          builder: (context, child, value) {
            return Icon(
              UniconsLine.ellipsis_h,
              color: value,
            );
          },
        ),
        onSelected: (IllustrationItemAction action) {
          widget.onPopupMenuItemSelected?.call(
            action,
            widget.index,
            widget.illustration,
          );
        },
        itemBuilder: (_) => widget.popupMenuEntries,
      ),
    );
  }

  /// If all thumbnails' urls are empty,
  /// try retrieve the urls from Firebase Storage
  /// and set them to the Firestore document.
  void checkProperties() async {
    final illustration = widget.illustration;

    if (illustration.hasPendingCreates) {
      return;
    }

    final thumbnailUrl = illustration.getThumbnail();
    if (thumbnailUrl.isNotEmpty) {
      return;
    }

    try {
      await IllustrationsActions.checkProperties(
        illustrationId: illustration.id,
      );
    } catch (error) {
      appLogger.e(error);
    }
  }
}
