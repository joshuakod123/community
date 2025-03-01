import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/model/post.dart';
import 'package:version1/provider/post_provider.dart'; // Adjust import as necessary

class PostScreen extends StatefulWidget {
  final String boardId;
  const PostScreen({Key? key, required this.boardId}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts([String searchText = '']) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (searchText.isEmpty) {
        await Provider.of<Posts>(context, listen: false)
            .fetchAndSetPosts(widget.boardId);
      } else {
        await Provider.of<Posts>(context, listen: false)
            .fetchAndSetPostsWithSearch(widget.boardId, searchText);
      }
    } catch (error) {
      _showError('Failed to load posts. Please try again later.');
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
    final postList = Provider.of<Posts>(context);
    final posts = postList.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _fetchPosts(value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : posts.isEmpty
                ? const Center(child: Text('No posts available.'))
                : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(posts[index].title??'No Title'),
                  subtitle: Text(posts[index].content ?? 'No Content'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await postList.deletePost(posts[index].id.toString());
                    },
                  ),
                  onTap: () {
                    // Navigate to a detailed post screen or edit screen
                    Navigator.pushNamed(
                      context,
                      '/post-detail', // Route to post details or edit page
                      arguments: posts[index].id, // Pass post ID
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-post'); // Route to add post page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
