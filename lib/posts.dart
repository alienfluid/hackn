import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'hnutils.dart';

const String _saved_pref_name = 'hackn_saved_post_ids';
const String _archived_pref_name = 'hackn_archived_post_ids';

/*
Post:
{
  "by" : "dhouston",
  "descendants" : 71,
  "id" : 8863,
  "kids" : [ 9224, 8952, 8917, 8884, 8887, 8869, 8940, 8908, 8958, 9005, 8873, 9671, 9067, 9055, 8865, 8881, 8872, 8955, 10403, 8903, 8928, 9125, 8998, 8901, 8902, 8907, 8894, 8870, 8878, 8980, 8934, 8943, 8876 ],
  "score" : 104,
  "time" : 1175714200,
  "title" : "My YC app: Dropbox - Throw away your USB drive",
  "type" : "story",
  "url" : "http://www.getdropbox.com/u/2/screencast.html"
}
*/

class PostWidget extends StatelessWidget {
  PostWidget(
      {Key key,
      this.author,
      this.id,
      this.score,
      this.time,
      this.title,
      this.type,
      this.url,
      this.descendants});

  final String author;
  final int id;
  final int score;
  final int time;
  final String title;
  final String type;
  final String url;
  final int descendants;

  @override
  Widget build(BuildContext context) {
    return new Container(
          margin: EdgeInsets.all(10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                    flex: 4,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(this.title != null ? this.title : 'Empty',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                              this.url != null
                                  ? shortenString(this.url)
                                  : 'Empty',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 12))
                        ])),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                      Text(this.score != null ? this.score.toString() : '-1'),
                      Text(this.descendants != null
                          ? this.descendants.toString()
                          : '-1')
                    ]))
              ]),
        );
  }

  factory PostWidget.fromJson(Map<String, dynamic> json) {
    return PostWidget(
      author: json['author'],
      id: json['id'],
      score: json['score'],
      time: json['time'],
      title: json['title'],
      type: json['type'],
      url: json['url'],
      descendants: json['descendants'],
    );
  }
}

Future<PostWidget> fetchPost(id) async {
  final response = await http.get(
      'https://hacker-news.firebaseio.com/v0/item/' + id.toString() + ".json");

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return PostWidget.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<Stream<Future<PostWidget>>> getPosts() async {
  var url = 'https://hacker-news.firebaseio.com/v0/topstories.json';

  var client = new http.Client();
  var streamedRes = await client.send(new http.Request('get', Uri.parse(url)));

  return streamedRes.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .expand((id) => id)
      .map((id) => fetchPost(id));
}

Future<List<Future<PostWidget>>> getSavedPosts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var ids = prefs.getStringList(_saved_pref_name);
  if (ids != null) {
    print("saved posts: " + ids.length.toString());
    var posts = ids.map((id) => fetchPost(int.parse(id))).toList();
    return posts;
  } else {
    print("saved posts null");
  }

  return null;
}

Future<List<Future<PostWidget>>> getArchivedPosts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var ids = prefs.getStringList(_archived_pref_name);
  if (ids != null) {
    print("archived posts: " + ids.length.toString());
    var posts = ids.map((id) => fetchPost(int.parse(id))).toList();
    return posts;
  } else {
    print("archived posts null");
  }

  return null;
}

savePost(PostWidget pw) {
  print("saving post - " + pw.title);
  persistPost(_saved_pref_name, pw);
}

archivePost(PostWidget pw) {
  print("archiving post - " + pw.title);
  persistPost(_archived_pref_name, pw);
}

persistPost(String loc, PostWidget pw) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var ids = prefs.getStringList(loc);

  if (ids != null) {
    ids.add(pw.id.toString());
  } else {
    ids = new List<String>();
    ids.add(pw.id.toString());
  }

  prefs.setStringList(loc, ids);
}
