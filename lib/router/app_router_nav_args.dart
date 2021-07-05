import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:flutter/widgets.dart';

/// Manage router navigation arguments.
/// Store arguments objects to re-use in other pages.
class AppRouterNavArgs {
  /// Last book selected.
  /// If null, no book has been selected yet.
  static Book? lastBookSelected;

  /// Last illustration selected.
  /// If null, no illustration has been selected yet.
  static Illustration? lastIllustrationSelected;

  /// Last selected image to edit (profile picture, ...).
  static ImageProvider<Object>? lastEditImageSelected;
}
