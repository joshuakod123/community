import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/Model/post.dart';
import 'package:version1/screen/add_post.dart';
import 'package:version1/screen/post_detail.dart';
import 'package:intl/intl.dart';
import 'package:version1/screen/search.dart';
import '../provider/board.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
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
        title: const Text('Boards', style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left),
        ),
        actions:[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:  _fetchPosts,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => SearchScreen(),));
            },
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
          return Column(
            children: [
              ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              ),
              if (index != posts.length - 1) const Divider(),
            ],
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
