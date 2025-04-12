import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addSampleNews() async {
  final firestore = FirebaseFirestore.instance;
  final newsCollection = firestore.collection('news');

  final sampleNews = [
    {
      'title': 'New Gaming Tournament Announced',
      'description':
          'A major gaming tournament has been announced for next month...',
      'date': Timestamp.now(),
      'imageUrl': 'https://example.com/gaming.jpg',
    },
    {
      'title': 'Academic Competition Results',
      'description': 'Results from the recent academic competition are in...',
      'date': Timestamp.now(),
      'imageUrl': 'https://example.com/academic.jpg',
    },
    // Add more sample news items
  ];

  for (var news in sampleNews) {
    await newsCollection.add(news);
  }
}
