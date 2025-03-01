import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/notification.dart';
import '../model/http_exception.dart';

class Notifications with ChangeNotifier {
  List<Notification> _items = [];
  final String? userId;

  Notifications(this.userId, this._items);

  List<Notification> get items {
    _items.sort((a, b) {
      return b.datetime!.compareTo(a.datetime!);
    });
    return [..._items];
  }

  // Fetch notifications for the given userId
  Future<void> fetchAndSetNotifications(String userId) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('notifications')
          .select()
          .eq('receiverId', userId)
          .order('datetime', ascending: false);


      final List<Notification> loadedNotifications = (response as List)
          .map((notificationData) => Notification(
        id: notificationData['id'],
        title: notificationData['title'],
        contents: notificationData['contents'],
        datetime: DateTime.parse(notificationData['datetime'])
            .toUtc()
            .add(Duration(hours: 9)),
        postId: notificationData['postId'],
        receiverId: notificationData['receiverId'],
      ))
          .toList();

      _items = loadedNotifications;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Add a new notification to Supabase
  Future<void> addNotification(Notification notification) async {
    final supabase = Supabase.instance.client;
    final timeStamp = DateTime.now().toIso8601String();

    try {
      final response = await supabase.from('notifications').insert({
        'title': notification.title,
        'contents': notification.contents,
        'datetime': timeStamp,
        'postId': notification.postId,
        'receiverId': notification.receiverId,
      });

      if (response.error != null) {
        throw response.error!;
      }

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Delete a notification by ID from Supabase
  Future<void> deleteNotification(String id) async {
    final supabase = Supabase.instance.client;
    final existingNotiIndex =
    _items.indexWhere((notification) => notification.id == id);
    Notification? existingNotification = _items[existingNotiIndex];
    _items.removeAt(existingNotiIndex);
    notifyListeners();

    final response = await supabase.from('notifications').delete().eq('id', id);
    if (response.error != null) {
      _items.insert(existingNotiIndex, existingNotification);
      notifyListeners();
      throw HttpException('Could not delete notification.');
    }
    existingNotification = null;
  }
}
