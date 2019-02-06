import 'package:flutter/material.dart';
import 'posts.dart';

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo
  final PostWidget post;

  // In the constructor, require a Todo
  DetailScreen({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[Icon(Icons.comment, color: Colors.white), Icon(Icons.open_in_browser, color: Colors.white)],
      ),
      body: Text(post.title),
    );
  }

}