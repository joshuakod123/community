import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:version1/Model/comment.dart';

class Comments with ChangeNotifier {
  List<Comment> _items = [];
  //final userId;
  Comments();

  List<Comment> get items {
    _items.sort((a, b) => a.datetime!.compareTo(b.datetime!));
    return [..._items];
  }

  // Initialize Supabase client
  final supabase = Supabase.instance.client;

  Future<void> fetchAndSetComments(int postId) async {
    try {
      final response = await supabase
          .from('comments')
          .select()
          .eq('postId', postId)
          .order('datetime', ascending: true);

      final List<Comment> loadedComments = (response as List<dynamic>)
          .map((commentData) => Comment(
        id: commentData['id'],
        postId: commentData['postId'],
        contents: commentData['contents'],
        datetime: DateTime.parse(commentData['datetime']),
        userId: commentData['userId'],
      )).toList();

      _items = loadedComments;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addComment(Comment comment) async {
    final timeStamp = DateTime.now().toUtc();
    try {
      String? userId = supabase.auth.currentUser?.userMetadata?['Display name'];
      final response = await supabase.from('comments').insert({
        'contents': comment.contents,
        'datetime': timeStamp.toIso8601String(),
        'postId': comment.postId,
        'userId': userId,
      }).select();


      final newComment = Comment(
        id: null,
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

  Future<void> deleteComment(int? id) async {
    final existingCommentIndex = _items.indexWhere((comment) => comment.id == id);
    var existingComment = _items[existingCommentIndex];
    _items.removeAt(existingCommentIndex);
    notifyListeners();
    final int id1 = id ?? 0;
    try {

      final response = await supabase.from('comments').delete().eq('id', id1);

      existingComment = Comment(
        id: null,
        postId: null,
        datetime: null,
        userId: null,
        contents: null,
      );
    } catch (error) {
      _items.insert(existingCommentIndex, existingComment);
      print(error);
      notifyListeners();
      throw error;
    }
  }
}


