import 'package:flutter/material.dart';

class Post_Comment extends StatefulWidget {
  @override
  _Post_CommentState createState() => _Post_CommentState();
}

class _Post_CommentState extends State<Post_Comment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * 1.6,
      child: Text('Post_Comment'),
    );
  }
}
