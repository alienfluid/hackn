import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

main () async {
  var posts = await getPosts();
  posts.listen((p) => 
    p.then((i) => print(i.title + " " + i.score.toString() + " " + i.id.toString()))
  );
}

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
    {Key key, this.author, this.id, this.score, this.time, this.title, this.type, this.url, this.descendants});

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
    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(this.title != null?this.title:'Empty', textAlign: TextAlign.left),
                    Text(this.url != null?this.url:'Empty', textAlign: TextAlign.left)
                  ])),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                Text(this.score != null?this.score.toString():'-1'),
                Text(this.descendants != null?this.descendants.toString():'-1')
              ]))
        ]));
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
  final response =
      await http.get('https://hacker-news.firebaseio.com/v0/item/' + id.toString() + ".json");

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