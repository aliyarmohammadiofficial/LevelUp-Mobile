import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum NotificationCategory { reminder, achievement, social, system }

/// A single entry in the Notifications list — a reminder firing, an
/// achievement unlock, community activity, or a system message.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  IconData get icon {
    switch (category) {
      case NotificationCategory.reminder:
        return Icons.alarm_rounded;
      case NotificationCategory.achievement:
        return Icons.emoji_events_rounded;
      case NotificationCategory.social:
        return Icons.people_alt_rounded;
      case NotificationCategory.system:
        return Icons.info_rounded;
    }
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      category: category,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, category, title, body, timestamp, isRead];
}
