import 'package:flutter_marketplace_template/models/category_tags_enums.dart';

/// Enum representing the type of people for a date
enum PeopleType { single, couple, withFriends, family }

/// Class representing the properties of a date
class DateProp {
  String idPlace;
  String title;
  String desc;
  (int, int) pricepp;
  PeopleType peopleType;
  String? photo;
  Category category;
  List<String>? tags;
  (Duration, Duration) time;

  DateProp({
    required this.idPlace,
    required this.title,
    required this.desc,
    required this.pricepp,
    required this.peopleType,
    this.photo,
    required this.category,
    required this.tags,
    required this.time,
  }) {
    if (tags != null && tags != []) {
      final allowed = allowedTags[category];
      if (!tags!.every((tag) => allowed?.contains(tag) ?? false)) {
        throw ArgumentError('Invalid tag(s) for category $category');
      }
    }
  }

  factory DateProp.fromOneJson(Map<String, dynamic> json) {
    final List<dynamic> datePropsTags = json['date_props_tags'] ?? [];

    final List<String> tags =
        datePropsTags
            .map((item) => item['tags']?['tag'])
            .where((tag) => tag != null)
            .cast<String>()
            .toList();

    return DateProp(
      idPlace: json['id_place'],
      title: json['title'],
      desc: json['desc'],
      pricepp: (json['pricepp_first'], json['pricepp_second']),
      peopleType: PeopleType.values[json['people_type']],
      photo: (json['photo']),
      category: Category.values.firstWhere(
        (c) => c.name == json['category'].toString(),
      ),
      tags: tags,
      time: (
        _parsePgInterval(json['time_first']),
        _parsePgInterval(json['time_second']),
      ),
    );
  }
}

Duration _parsePgInterval(String value) {
  // format "HH:MM:SS"
  final parts = value.split(':');
  if (parts.length == 3) {
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
  throw FormatException('Nieobsługiwany format interval: $value');
}
