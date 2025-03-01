import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/Model/post.dart';
import 'package:version1/provider/post_provider.dart'; // Adjust import as necessary
import 'package:version1/screen/add_post.dart';

import '../provider/board.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({Key? key}) : super(key: key);

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<PostList>(context, listen: false).fetchAndSetPosts();
    } catch (error) {
      _showError('Failed to load posts. Please try again later.Error: $error');
      print(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postList = Provider.of<PostList>(context);
    final posts = postList.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boards'),
        actions:[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:  _fetchPosts,
          ),
        ]
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(child: Text('No posts available.'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (ctx, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(post.title ?? 'Untitled'),
              subtitle: Text(
                post.content != null && post.content!.length > 50
                    ? '${post.content!.substring(0, 50)}...'
                    : post.content ?? 'No content available.',
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/post-detail', // Route to post details page
                  arguments: post.id, // Pass post ID
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPostScreen(),
            ),
          );
          if(result ==true){
            _fetchPosts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
