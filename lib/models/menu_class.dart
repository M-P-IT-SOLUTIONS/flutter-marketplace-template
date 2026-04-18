
/// Represents a menu with groups of items
class MenuClass {
  List<GroupItem> groups = [];

  MenuClass(this.groups);

  Map<String, dynamic> toJson() {
    return {
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }

  factory MenuClass.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MenuClass([]);
    }

    return MenuClass(
      (json['groups'] as List)
          .map((group) => GroupItem.fromJson(group))
          .toList(),
    );
  }
}

/// Represents a group of items within a menu
class GroupItem {
  String title;
  List<(String, int)> elements = []; //krotki nazwa, cena

  GroupItem({required this.title, required this.elements});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'elements': elements.map((e) => {'name': e.$1, 'price': e.$2}).toList(),
    };
  }

  factory GroupItem.fromJson(Map<String, dynamic> json) {
    return GroupItem(
      title: json['title'],
      elements: (json['elements'] as List)
          .map((e) => (e['name'] as String, e['price'] as int))
          .toList(),
    );
  }
}
