import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:version1/Model/post.dart';
import 'package:flutter/cupertino.dart';

class PostList with ChangeNotifier {
  List<Post> _items = [];

  late final SupabaseClient supabaseClient;

  PostList(this.supabaseClient);

  List<Post> get items {
    return [..._items];
  }

  Future<void> fetchAndSetPosts() async {
    try {
      // Query the 'posts' table
      final response = await supabaseClient
          .from('posts')
          .select();

      final data = response as List<dynamic>;

      final List<Post> loadedPosts = data.map((postData) {
        return Post(
          id: postData['id'],
          title: postData['title'],
          content: postData['content'],
          datetime: postData['datetime'] != null
              ? DateTime.parse(postData['datetime'])
              : null,
          imgURL: postData['imgURL'],
          userId: postData['creatorId'],
          initialLikes: postData['likes'],
        );
      }).toList();

      _items = loadedPosts;
      print(this.items);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}