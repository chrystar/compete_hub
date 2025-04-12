import 'package:flutter/material.dart';

enum EventCategory {
  games,
  academics,
  music,
  art,
  technology;


  IconData get icon {
    switch (this) {
      case EventCategory.games:
        return Icons.sports_esports;
      case EventCategory.academics:
        return Icons.school;
      case EventCategory.music:
        return Icons.music_note;
      case EventCategory.art:
        return Icons.palette;
      case EventCategory.technology:
        return Icons.computer;
    }
  }
}
