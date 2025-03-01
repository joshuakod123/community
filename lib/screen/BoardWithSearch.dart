import 'package:flutter/material.dart';
import 'package:version1/screen/post_detail.dart';
import 'package:provider/provider.dart';
import '../provider/post_provider.dart';
import 'package:intl/intl.dart';

class BoardSearch extends StatefulWidget {
  final search;

  const BoardSearch({super.key, required this.search});

  @override
  State<BoardSearch> createState() => _BoardSearchState();
}

class _BoardSearchState extends State<BoardSearch> {
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Posts>(context, listen: false).fetchAndSetPostsWithSearch(widget.search);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts. Please try again later.Error: $error')),
      );
      print(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postList = Provider.of<Posts>(context);
    final posts = postList.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Result for  ${widget.search}',
          style: const TextStyle(fontWeight: FontWeight.bold ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
          :posts.isEmpty
        ?const Center(child: Text('Result Not Found'))
          : ListView.builder(
        itemCount: posts.length,
          itemBuilder: (ctx, index){
            final post = posts[index];
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Text(
                    post.title != null && post.content!.length>60
                        ? '${post.title!.substring(0,60)}...'
                        : post.title??'NoTitle',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      post.content != null && post.content!.length > 50
                          ? '${post.content!.substring(0, 50)}...'
                          : post.content ?? 'No content available.',
                      style: const TextStyle (color: Colors.grey)
                  ),
                  Text(
                    post.datetime != null
                        ? "${DateFormat('HH:mm').format(post.datetime!)} | ${post.userId}"
                        : '',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(posts : post),
                  ),
                );
              },
            );
          }
      ),
    );
  }
}
