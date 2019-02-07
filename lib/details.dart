import 'package:flutter/material.dart';
import 'posts.dart';
import 'hnutils.dart';

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo
  final PostWidget post;

  // In the constructor, require a Todo
  DetailScreen({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
        ],
      ),
      body: DetailTile(post: this.post),
    );
  }
}

class DetailTile extends StatelessWidget {
  final PostWidget post;

  DetailTile({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: Text(this.post.title, textScaleFactor: 1.2))
            ]),
            Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(children: <Widget>[
                  Text(this.post.author),
                  Spacer(flex: 4),
                  Text(getHumanTime(this.post.time)),
                  Spacer(flex: 4),
                  Icon(Icons.thumb_up, color: Colors.grey),
                  Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(
                        "345",
                        textScaleFactor: 1.2,
                      )),
                  Spacer(),
                  Icon(Icons.comment, color: Colors.grey),
                  Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text("456", textScaleFactor: 1.2)),
                ])),
            Container(
                padding: EdgeInsets.all(10.0),
                child: Row(children: <Widget>[
                  Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: Icon(Icons.open_in_browser)),
                  Expanded(child: Text(shortenString(this.post.url))),
                ])),
            Container(
                padding: EdgeInsets.all(10.0),
                child: Row(children: <Widget>[
                  Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: Icon(Icons.open_in_browser)),
                  Expanded(child: Text(shortenString(getHNUrl(this.post.id)))),
                ])),
          ],
        ));
  }
}
