import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:version1/model/post.dart';

class Posts with ChangeNotifier {
  List<Post> _items = [];
  final SupabaseClient supabaseClient;

  Posts(this.supabaseClient);

  List<Post> get items {
    _items.sort((a, b) => b.datetime!.compareTo(a.datetime!));
    return [..._items];
  }

  Future<void> fetchAndSetPosts(String boardId) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select()
          .eq('boardId', boardId)
          .order('datetime', ascending: false);

      final data = response as List<dynamic>;

      _items = data.map((postData) {
        return Post(
          id: postData['id'],
          title: postData['title'],
          content: postData['text'],
          datetime: DateTime.parse(postData['datetime']),
          imgURL: postData['IMGURL'],
          userId: postData['creatorId'],
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      print("Error fetching posts: $error");
      rethrow;
    }
  }

  Future<void> fetchAndSetPostsWithSearch(String boardId, String searchText) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select()
          .eq('boardId', boardId)
          .like('title', '%$searchText%')
          .or('contents.ilike.%$searchText%')
          .order('datetime', ascending: false);

      final data = response as List<dynamic>;

      _items = data.map((postData) {
        return Post(
          id: postData['id'],
          title: postData['title'],
          content: postData['contents'],
          datetime: DateTime.parse(postData['datetime']),
          imgURL: postData['IMGURL'],
          userId: postData['creatorId'],
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      print("Error fetching posts with search: $error");
      rethrow;
    }
  }

  Future<void> addPost(Post post) async {
    final timeStamp = DateTime.now();
    final userId = supabaseClient.auth.currentUser?.id;

    try {
      final response = await supabaseClient.from('posts').insert({
        'title': post.title,
        'content': post.content,
        'datetime': timeStamp.toIso8601String(),
        'imgURL': post.imgURL,
        'creatorId': userId,
      });

      //final newPostId = response.data[0]['id'];
      final newPostId = 0;

      final newPost = Post(
        id: newPostId,
        title: post.title,
        content: post.content,
        datetime: timeStamp,
        imgURL: post.imgURL,
        userId: userId,
      );

      _items.add(newPost);
      notifyListeners();
    } catch (error) {
      print("Error adding post: $error");
      rethrow;
    }
  }

  Future<void> updatePost(String id, Post newPost) async {
    try {
      final response = await supabaseClient.from('posts').update({
        'title': newPost.title,
        'contents': newPost.content,
      }).eq('id', id);

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      final postIndex = _items.indexWhere((post) => post.id == id);
      if (postIndex >= 0) {
        _items[postIndex] = newPost;
        notifyListeners();
      }
    } catch (error) {
      print("Error updating post: $error");
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    final existingPostIndex = _items.indexWhere((post) => post.id == id);
    Post? existingPost = _items[existingPostIndex];
    _items.removeAt(existingPostIndex);
    notifyListeners();

    try {
      final response = await supabaseClient.from('posts').delete().eq('id', id);

      if (response.error != null) {
        throw Exception(response.error!.message);
      }
    } catch (error) {
      _items.insert(existingPostIndex, existingPost);
      notifyListeners();
      print("Error deleting post: $error");
      rethrow;
    }
  }
}
