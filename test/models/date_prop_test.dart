import 'package:flutter_test/flutter_test.dart';
import 'package:randki/models/category_tags_enums.dart';
import 'package:randki/models/date_prop.dart';

void main() {
  group('DateProp', () {
    test('creates a model from JSON and parses intervals and tags', () {
      final dateProp = DateProp.fromOneJson({
        'id_place': 'place-1',
        'title': 'Weekend dinner',
        'desc': 'A nice dinner spot',
        'pricepp_first': 120,
        'pricepp_second': 180,
        'people_type': 0,
        'photo': 'https://example.com/photo.png',
        'category': 'restaurant',
        'date_props_tags': [
          {
            'tags': {'tag': 'italian'},
          },
          {
            'tags': {'tag': 'casual dining'},
          },
        ],
        'time_first': '01:30:15',
        'time_second': '02:00:00',
      });

      expect(dateProp.idPlace, 'place-1');
      expect(dateProp.title, 'Weekend dinner');
      expect(dateProp.desc, 'A nice dinner spot');
      expect(dateProp.pricepp, (120, 180));
      expect(dateProp.peopleType, PeopleType.single);
      expect(dateProp.photo, 'https://example.com/photo.png');
      expect(dateProp.category, Category.restaurant);
      expect(dateProp.tags, ['italian', 'casual dining']);
      expect(
        dateProp.time.$1,
        const Duration(hours: 1, minutes: 30, seconds: 15),
      );
      expect(dateProp.time.$2, const Duration(hours: 2));
    });

    test('rejects tags that do not belong to the selected category', () {
      expect(
        () => DateProp(
          idPlace: 'place-2',
          title: 'Invalid tag example',
          desc: 'Should fail',
          pricepp: (0, 0),
          peopleType: PeopleType.couple,
          category: Category.cafe,
          tags: const ['italian'],
          time: (Duration.zero, Duration.zero),
        ),
        throwsArgumentError,
      );
    });

    test('accepts empty or null tags without validation errors', () {
      final noTags = DateProp(
        idPlace: 'place-3',
        title: 'No tags',
        desc: 'Valid empty tags',
        pricepp: (0, 0),
        peopleType: PeopleType.family,
        category: Category.chill,
        tags: const [],
        time: (Duration.zero, Duration.zero),
      );

      final nullTags = DateProp(
        idPlace: 'place-4',
        title: 'Null tags',
        desc: 'Valid null tags',
        pricepp: (0, 0),
        peopleType: PeopleType.withFriends,
        category: Category.chill,
        tags: null,
        time: (Duration.zero, Duration.zero),
      );

      expect(noTags.tags, isEmpty);
      expect(nullTags.tags, isNull);
    });
  });
}
