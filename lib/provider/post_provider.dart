import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:version1/Model/post.dart';
import '../main.dart';

class Posts with ChangeNotifier {
  List<Post> _items = [];
  final supabaseClient = Supabase.instance.client;


  List<Post> get items {
    _items.sort((a, b) => b.datetime!.compareTo(a.datetime!));
    return [..._items];
  }

  Future<void> addPost(Post post) async {
    final timeStamp = DateTime.now();
    String? userId = supabaseClient.auth.currentUser?.userMetadata?['Display name'];

    try {
      final response = await supabaseClient.from('posts').insert({
        'title': post.title,
        'content': post.content,
        'datetime': timeStamp.toIso8601String(),
        'imgURL': post.imgURL,
        'creatorId': userId,
      });


      final newPost = Post(
        id: null,
        title: post.title,
        content: post.content,
        datetime: timeStamp,
        imgURL: post.imgURL,
        userId: userId,
        initialLikes: 0,
      );
      _items.add(newPost);
      notifyListeners();
    } catch (error) {
      print("Error adding post: $error");
      rethrow;
    }
  }

  Future<void> fetchAndSetPostsWithSearch(String searchText) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select()
          .like('title', '%$searchText%')
          .or('content.ilike.%$searchText%')
          .order('datetime', ascending: false);

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
          userId: postData['userId'],
          initialLikes: postData['likes'],
        );
      }).toList();

      _items = loadedPosts;

      notifyListeners();
    } catch (error) {
      print("Error fetching posts with search: $error");
      rethrow;
    }
  }

  Future<void> deletePost(int? id) async {
    print(id);
    final int id1 = id ?? 0;
    notifyListeners();

    try {
      final response = await supabase.from('posts').delete().eq('id', id1);

    } catch (error) {
      notifyListeners();
      print("Error deleting post: $error");
      rethrow;
    }
  }

  Future<void> fetchThreePosts() async {
    try {
      final _response = await supabaseClient
          .from('posts')
          .select()
          .order('datetime', ascending: false)
          .limit(5) ;


      final data = _response as List<dynamic>;

      final List<Post> loadedPosts = data.map((postData) {
        return Post(
          id: postData['id'],
          title: postData['title'],
          content: postData['contents'],
          datetime: DateTime.parse(postData['datetime']),
          userId: postData['creatorId'],
          initialLikes: postData['likes'],
        );
      }).toList();

      _items = loadedPosts;
      notifyListeners();
    } catch (error) {
      print("Error fetching three posts: $error");
      rethrow;
    }
  }
}
