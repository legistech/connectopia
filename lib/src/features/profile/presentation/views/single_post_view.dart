import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';
import '../../../feeds/presentation/views/single_post.dart';
import '../../domain/models/post.dart';

class SinglePostView extends StatelessWidget {
  const SinglePostView(
      {super.key,
      required this.post,
      required this.isOwnPost,
      required this.posts});
  final Post post;
  final bool isOwnPost;
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Pellet.kBackgroundGradient,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('POST'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: SinglePostTemplate(
            post: post,
            isOwnPost: isOwnPost,
            posts: posts,
          ),
        ),
      ),
    );
  }
}
