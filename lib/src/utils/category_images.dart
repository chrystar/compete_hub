import '../models/event_category.dart' as event_category;

class CategoryImages {
  static String getImageForCategory(event_category.EventCategory category) {
    final basePath = 'assets/images/categories';
    switch (category) {
      case event_category.EventCategory.games:
        return '$basePath/gaming.pg';

      case event_category.EventCategory.music:
        return '$basePath/music.png';
      case event_category.EventCategory.art:
        return '$basePath/art.png';
      case event_category.EventCategory.academics:
        return '$basePath/academics.png';
      case event_category.EventCategory.technology:
        return '$basePath/technology.jpg';
    }
  }
}
