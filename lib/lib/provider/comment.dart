import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/http_exception.dart';
import '../model/Comment.dart';

class Comments with ChangeNotifier {
  List<Comment> _items = [];
  final String? authToken;
  final String? userId;

  Comments(this.authToken, this.userId, this._items);

  List<Comment> get items {
    _items.sort((a, b) => a.datetime!.compareTo(b.datetime!));
    return [..._items];
  }

  // Initialize Supabase client
  final supabase = Supabase.instance.client;

  Future<void> fetchAndSetComments(String postId) async {
    try {
      final response = await supabase
          .from('comments')
          .select()
          .eq('postId', postId)
          .order('datetime', ascending: true);

      /*if (response.error != null) {
        throw Exception(response.error!.message);
      }*/

      final List<Comment> loadedComments = (response as List<dynamic>)
          .map((commentData) => Comment(
        id: commentData['id'],
        postId: commentData['postId'],
        contents: commentData['contents'],
        datetime: DateTime.parse(commentData['datetime']),
        userId: commentData['creatorId'],
      ))
          .toList();

      _items = loadedComments;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addComment(Comment comment) async {
    final timeStamp = DateTime.now().toUtc();
    try {
      final response = await supabase.from('comments').insert({
        'id': comment.id, // Ensure `id` is specified if required by schema
        'contents': comment.contents,
        'datetime': timeStamp.toIso8601String(),
        'postId': comment.postId,
        'creatorId': userId,
      }).select();

      /*if (response.error != null) {
        throw HttpException(response.error!.message);
      }*/

      final newComment = Comment(
        id: response[0]['id'],
        contents: comment.contents,
        datetime: timeStamp,
        postId: comment.postId,
        userId: userId,
      );

      _items.add(newComment);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteComment(String id) async {
    final existingCommentIndex = _items.indexWhere((comment) => comment.id == id);
    var existingComment = _items[existingCommentIndex];
    _items.removeAt(existingCommentIndex);
    notifyListeners();

    try {
      final response = await supabase.from('comments').delete().eq('id', id);

      if (response.error != null) {
        _items.insert(existingCommentIndex, existingComment);
        notifyListeners();
        throw HttpException('Could not delete Comment');
      }

      existingComment = Comment(
        id: null,
        postId: null,
        datetime: null,
        userId: null,
        contents: null,
      );
    } catch (error) {
      _items.insert(existingCommentIndex, existingComment);
      notifyListeners();
      throw error;
    }
  }
}


