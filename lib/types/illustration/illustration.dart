import 'package:artbooking/types/acl.dart';
import 'package:artbooking/types/author.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/dimensions.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/types/illustration/stats.dart';
import 'package:artbooking/types/illustration/version.dart';
import 'package:artbooking/types/illustration/urls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Illustration {
  /// Access Control List managing this illustration visibility to others users.
  List<ACL> acl;

  /// Author's illustration.
  Author author;

  /// Illustration's style (e.g. pointillism, realism) — Limited to 5.
  List<String> categories;

  /// The time this illustration has been created.
  final DateTime createdAt;

  /// This illustration's description.
  String description;

  /// This Illustration's dimensions.
  Dimensions dimensions;

  /// File's extension.
  String extension;

  /// Firestore id.
  String id;

  /// Specifies how this illustration can be used.
  IllustrationLicense license;

  /// This illustration's name.
  String name;

  /// Cloud Storage file's size in bytes.
  final int size;

  /// Downloads, favourites, shares, views... of this illustration.
  IllustrationStats stats;
  final DateTime updatedAt;
  Urls urls;
  List<IllustrationVersion> versions;
  ContentVisibility visibility;

  Illustration({
    this.acl = const [],
    this.author,
    this.categories = const [],
    this.createdAt,
    this.description = '',
    this.dimensions,
    this.extension = '',
    this.id = '',
    this.license,
    this.name = '',
    this.stats,
    this.size = 0,
    this.updatedAt,
    this.urls,
    this.versions = const [],
    this.visibility,
  });

  factory Illustration.fromJSON(Map<String, dynamic> data) {
    return Illustration(
      author: Author.fromJSON(data['author']),
      categories: parseCategories(data['categories']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'],
      dimensions: Dimensions.fromJSON(data['dimensions']),
      extension: data['extension'],
      id: data['id'],
      license: IllustrationLicense.fromJSON(data['license']),
      name: data['name'],
      stats: IllustrationStats.fromJSON(data['stats']),
      size: data['size'],
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      urls: Urls.fromJSON(data['urls']),
      versions: [],
      visibility: parseVisibility(data['visibilty']),
    );
  }

  String getThumbnail() {
    final t360 = urls.thumbnails.t360;
    if (t360 != null && t360.isNotEmpty) {
      return t360;
    }

    final t480 = urls.thumbnails.t480;
    if (t480 != null && t480.isNotEmpty) {
      return t480;
    }

    final t720 = urls.thumbnails.t720;
    if (t720 != null && t720.isNotEmpty) {
      return t720;
    }

    final t1080 = urls.thumbnails.t1080;
    if (t1080 != null && t1080.isNotEmpty) {
      return t1080;
    }

    return urls.original;
  }

  static List<String> parseCategories(Map<String, dynamic> data) {
    final results = <String>[];

    if (data == null) {
      return results;
    }

    data.forEach((key, value) {
      results.add(key);
    });

    return results;
  }

  static ContentVisibility parseVisibility(String stringVisiblity) {
    switch (stringVisiblity) {
      case 'acl':
        return ContentVisibility.acl;
      case 'challenge':
        return ContentVisibility.challenge;
        break;
      case 'contest':
        return ContentVisibility.contest;
        break;
      case 'gallery':
        return ContentVisibility.gallery;
        break;
      case 'private':
        return ContentVisibility.private;
        break;
      case 'public':
        return ContentVisibility.public;
        break;
      default:
        return ContentVisibility.private;
    }
  }

  String visibilityToString() {
    switch (visibility) {
      case ContentVisibility.acl:
        return 'acl';
      case ContentVisibility.challenge:
        return 'challenge';
      case ContentVisibility.contest:
        return 'contest';
      case ContentVisibility.private:
        return 'private';
      case ContentVisibility.public:
        return 'public';
      default:
        return 'private';
    }
  }
}