import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:version1/Model/post.dart';
import 'package:version1/provider/comment.dart';
import 'package:version1/Model/comment.dart';
import 'package:version1/screen/search.dart';

import '../main.dart';
import '../provider/comment.dart';
import '../provider/post_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post posts;

  const PostDetailScreen({super.key, required this.posts});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLoading = false;
  final _commentController = TextEditingController();
  String? _postCreator;
  bool isLiked = false;
  late int? likesCount;


  @override
  void initState() {
    super.initState();
    _fetchPostCreator();
    _fetchComments();
    likesCount = widget.posts.initialLikes;
    print(likesCount);
    checkIfLiked();
  }


  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Comments>(context, listen: false)
        .fetchAndSetComments(widget.posts.id!);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchPostCreator() async{
    try{
      final response = await supabase.from('posts').select('creatorId').eq('id',widget.posts.id as Object).single();
      if (response != null) {
        setState(() {
          _postCreator = response['creatorId'] as String;
        });
      }
    }catch (error){
      print('postCreatorfetcherror:$error');
    }
  }



  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final newComment = Comment(
      id: null,
      postId: widget.posts.id,
      contents: _commentController.text.trim(),
      datetime: DateTime.now(),
      userId: supabase.auth.currentUser?.userMetadata?['DisplayName'],
    );

    try {
      await Provider.of<Comments>(context, listen: false).addComment(newComment);
      _commentController.clear();
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment. Please try again.')),
      );
    }
  }

  void dispose(){
    _commentController.dispose();
    super.dispose();
  }

  Future<void> checkIfLiked() async{
    final _userId = supabase.auth.currentUser?.userMetadata?['Display name'];
    String? _postUserId = widget.posts.userId ?? '';
    final response = await supabase.from('likes').select()
        .match({'user_id': _userId, 'post_id': _postUserId}).single();
    setState((){
      isLiked = response !=null;
    });
  }

  Future<void> likePost() async {
    if (isLiked) return;

    final userId = supabase.auth.currentUser?.id;

    try {
      await supabase.from('likes').insert({
        'user_id': userId,
        'post_id': widget.posts.id,
      });

      if(likesCount!=null){
        await supabase.from('posts').update({
          'likes': likesCount! + 1
        }).eq('id', widget.posts.id as Object);

        setState(() {
          isLiked = true;
          likesCount=likesCount!+ 1;
        });
      }

    } catch (e) {
      print('Error liking post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsData = Provider.of<Comments>(context);
    final comments = commentsData.items;
    String? _user = supabase.auth.currentUser?.userMetadata?['Display name'];


    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post title
              Text(
                widget.posts.title ?? 'Untitled',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
        
              // Date and Time
              Row(
                children: [
                  Text(
                    widget.posts.datetime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(widget.posts.datetime!)
                        : 'No date available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  if (_postCreator == _user)
                    IconButton(
                      onPressed: () async {
                        await Provider.of<Posts>(context, listen: false)
                            .deletePost(widget.posts.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                    )
                  else
                    const SizedBox.shrink(),
                    Text(' $_postCreator')
                ],
              ),

              const SizedBox(height: 10),
        
              // Post Content
              Text(
                widget.posts.content ?? 'No content available',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
        
              // Image (optional)
              if (widget.posts.imgURL != null && widget.posts.imgURL!.isNotEmpty)
                Image.network(
                  widget.posts.imgURL!,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Could not load image.');
                  },
                ),


              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: (){
                      setState(() {
                        likePost;
                      });
                    },
                  ),
                  Text('${widget.posts.initialLikes}')
                ],
              ),
              const SizedBox(height: 20),

              // Comments Section
              const Divider(),
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
        
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitComment,
                    ),
                  ],
                ),
              ),
        
              // Display comments or loading indicator
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                  ? const Text('No comments yet.')
                  : SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (ctx, index) => ListTile(
                    leading: Icon(Icons.person, color: Colors.grey[600]),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comments[index].userId ?? '',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(comments[index].contents ?? ''),
                      ],
                    ),
                    subtitle: Text(
                      comments[index].datetime != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(
                        comments[index].datetime!,
                      )
                          : '',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    trailing: comments[index].userId == _user
                        ?IconButton(
                      onPressed: () async {
                        await Provider.of<Comments>(context, listen: false).deleteComment(comments[index].id);
                      },
                      icon: const Icon(Icons.delete),
                    )
                    :IconButton(
                      onPressed: (){
                        print(comments[index].userId);
                      },
                      icon: const Icon(Icons.favorite),
                    ),
                  ),
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }
}
