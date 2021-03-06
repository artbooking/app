import 'package:artbooking/types/user/stats.dart';
import 'package:artbooking/types/user/settings.dart';
import 'package:artbooking/types/user/user_urls.dart';
import 'package:artbooking/types/user/user_pp.dart';
import 'package:artbooking/utils/date_helper.dart';

class UserFirestore {
  DateTime? createdAt;
  String email;
  final String id;
  String job;
  String lang;
  String location;
  String? name;
  String nameLowerCase;
  final UserPP? pp;
  String pricing;
  UserSettings? settings;
  UserStats? stats;
  String? summary;
  String? uid;
  DateTime? updatedAt;
  UserUrls? urls;

  UserFirestore({
    this.createdAt,
    this.email = '',
    required this.id,
    this.job = '',
    this.location = '',
    this.lang = 'en',
    this.name = '',
    this.nameLowerCase = '',
    this.pp,
    this.pricing = 'free',
    this.settings,
    this.stats,
    this.summary,
    this.uid,
    this.updatedAt,
    this.urls,
  });

  factory UserFirestore.empty() {
    return UserFirestore(
      createdAt: DateTime.now(),
      email: 'anonymous@rootasjey.dev',
      id: '',
      job: 'Ghosting',
      lang: 'en',
      location: 'Nowhere',
      name: 'Anonymous',
      nameLowerCase: 'anonymous',
      pp: UserPP.empty(),
      pricing: 'free',
      summary: 'An anonymous user ghosting decent people.',
      stats: UserStats.empty(),
      updatedAt: DateTime.now(),
      urls: UserUrls.empty(),
    );
  }

  factory UserFirestore.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserFirestore.empty();
    }

    return UserFirestore(
      createdAt: DateHelper.fromFirestore(data['createdAt']),
      email: data['email'] ?? '',
      id: data['id'] ?? '',
      job: data['job'] ?? 'Uknown',
      lang: data['lang'] ?? 'en',
      location: data['location'] ?? 'Nowhere',
      name: data['name'],
      nameLowerCase: data['nameLowerCase'] ?? '',
      pp: UserPP.fromJSON(data['pp']),
      pricing: data['pricing'] ?? 'free',
      stats: UserStats.fromJSON(data['stats']),
      summary: data['summary'] ?? '',
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
      urls: UserUrls.fromJSON(data['urls']),
    );
  }

  Map<String, dynamic> toJSON({bool withAllFields = false}) {
    Map<String, dynamic> data = Map();

    if (withAllFields) {
      data['email'] = email;
      data['name'] = name;
      data['nameLowerCase'] = nameLowerCase;
    }

    data['job'] = job;
    data['lang'] = lang;
    data['location'] = location;
    data['pp'] = pp!.toJSON();
    data['pricing'] = pricing;
    data['summary'] = summary;
    data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    data['urls'] = urls!.toJSON();

    return data;
  }

  /// Return user's profile picture if any.
  /// If [placeholder] is `true`, the method will return
  /// a default picture if the user hasn't set one.
  String getPP() {
    final edited = pp!.url!.edited;
    final original = pp!.url!.original;
    final defaultUrl =
        "https://img.icons8.com/plasticine/100/000000/flower.png";

    if (edited != null && edited.isNotEmpty) {
      return edited;
    }

    if (original != null && original.isNotEmpty) {
      return original;
    }

    return defaultUrl;
  }
}
