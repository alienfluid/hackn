import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'posts.dart';
import 'hnutils.dart';
import 'comments.dart';

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo
  final PostWidget post;

  // In the constructor, require a Todo
  DetailScreen({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[],
        ),
        body: Column(children: <Widget>[
          DetailTile(post: this.post),
          Expanded(child: new CommentThreadList(post: this.post))
        ]));
  }
}

class CommentThreadList extends StatefulWidget {
  CommentThreadList({Key key, @required this.post}) : super(key: key);

  final PostWidget post;

  @override
  _CommentThreadListState createState() => _CommentThreadListState();
}

class _CommentThreadListState extends State<CommentThreadList> {
  var threadList = <CommentThread>[];

  @override
  initState() {
    super.initState();
    listenForComments();
  }

  listenForComments() async {
    var stream = await getComments(widget.post);
    stream.listen((thread) {
      if (this.mounted) {
        setState(() {
          threadList.add(thread);
        });
      }
    }, onDone: () {});
  }

  Widget formatComment(String c) {
    if (c == null) {
      return Text("");
    } else {
      return Html(data: c);
    }
  }

  Widget formatAuthor(String author, int time) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Row(children: <Widget>[
          Icon(Icons.person, color: Colors.blueGrey),
          Text(author, style: TextStyle(color: Colors.deepOrange)),
          Spacer(),
          Text(getTimeAgo(time)),
          Spacer(flex: 8)
        ]));
  }

  List<Widget> composeComments(CommentThread t, int depth, List<Widget> acc) {
    if (t.root.deleted == null || t.root.deleted != true) {
      var x = Container(
          padding: EdgeInsets.fromLTRB(5 + (depth * 8.0), 5, 0, 0),
          child: Column(children: <Widget>[
            formatAuthor(t.root.author, t.root.time),
            formatComment(t.root.text)
          ]));

      acc.add(x);
    }

    for (final c in t.children) {
      composeComments(c, depth + 1, acc);
    }

    return acc;
  }

  Widget renderThread(CommentThread t, int depth) {
    List<Widget> v = composeComments(t, depth, new List<Widget>());
    return Column(children: v);
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        shrinkWrap: true,
        itemCount: threadList.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return renderThread(threadList[index], 0);
        });
  }
}

class DetailTile extends StatelessWidget {
  final PostWidget post;

  DetailTile({Key key, @required this.post}) : super(key: key);

  _launchURL(url) async {
    await launch(url);
  }

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
                  Text(this.post.author,
                      style: TextStyle(color: Colors.deepOrange)),
                  Spacer(flex: 4),
                  Text(getHumanTime(this.post.time)),
                  Spacer(flex: 4),
                  Icon(Icons.thumb_up, color: Colors.grey),
                  Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(
                        this.post.score.toString(),
                        textScaleFactor: 1.2,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Spacer(),
                  Icon(Icons.comment, color: Colors.grey),
                  Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(this.post.descendants.toString(),
                          textScaleFactor: 1.2,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ])),
            InkWell(
                onTap: () => _launchURL(this.post.url),
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Icon(Icons.open_in_browser)),
                      Expanded(child: Text(shortenString(this.post.url))),
                    ]))),
            InkWell(
                onTap: () => _launchURL(getHNUrl(this.post.id)),
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Icon(Icons.open_in_browser)),
                      Expanded(
                          child: Text(shortenString(getHNUrl(this.post.id)))),
                    ]))),
          ],
        ));
  }
}
