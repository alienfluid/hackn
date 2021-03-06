import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'dart:convert';
import 'dart:async';
import 'hnutils.dart';
import 'details.dart';

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
      this.descendants,
      this.kids});

  final String author;
  final int id;
  final int score;
  final int time;
  final String title;
  final String type;
  final String url;
  final int descendants;
  final List<int> kids;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(post: this),
            )),
        child: Container(
          margin: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                  Widget>[
            Expanded(
                flex: 4,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(this.title != null ? this.title : 'Empty',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                          padding: EdgeInsets.all(2),
                          child: Row(children: <Widget>[
                            Text(this.author,
                                style: TextStyle(fontStyle: FontStyle.italic)),
                            Spacer(),
                            Text(getTimeAgo(this.time)),
                            Spacer(flex: 8)
                          ])),
                      Text(this.url != null ? shortenString(this.url) : 'Empty',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12)),
                    ])),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                  SpeechBubble(
                      child: Text(
                          this.descendants != null
                              ? this.descendants.toString()
                              : '0',
                          textScaleFactor: 1.1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                ]))
          ]),
        ));
  }

  factory PostWidget.fromJson(Map<String, dynamic> json) {
    var k = json['kids'];
    var kids;
    if (k != null) {
      kids = new List<int>.from(k);
    } else {
      kids = new List<int>();
    }

    return PostWidget(
      author: json['by'],
      id: json['id'],
      score: json['score'],
      time: json['time'],
      title: json['title'],
      type: json['type'],
      url: json['url'],
      descendants: json['descendants'],
      kids: kids,
    );
  }
}

Future<PostWidget> fetchPost(id, httpClient) async {
  final response = await httpClient.get(
      'https://hacker-news.firebaseio.com/v0/item/' + id.toString() + ".json");

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return PostWidget.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

Stream<PostWidget> streamPosts(List<int> ids, List<int> toFilter) async* {
  var client = new http.Client();

  for (final id in ids) {
    if (toFilter != null) {
      if (toFilter.contains(id)) {
        continue;
      }
    }
    var x = await fetchPost(id, client);
    yield x;
  }
}

Future<Stream<PostWidget>> getPosts() async {
  var url = 'https://hacker-news.firebaseio.com/v0/topstories.json';

  var client = new http.Client();
  var response = await client.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<int> ids = l.map((id) => id as int).toList();

    var savedIds = await getPostIds(_saved_pref_name);
    var archivedIds = await getPostIds(_archived_pref_name);

    List<int> iids;
    if (savedIds != null) {
      iids = savedIds.map((i) => int.parse(i)).toList();
    }
    if (archivedIds != null) {
      if (iids != null) {
        iids.addAll(archivedIds.map((i) => int.parse(i)).toList());
      } else {
        iids = archivedIds.map((i) => int.parse(i)).toList();
      }
    }
    return streamPosts(ids, iids);
  } else {
    throw Exception('Failed to get top posts');
  }
}

Future<Stream<PostWidget>> getPersistedPosts(loc) async {
  var ids = await getPostIds(loc);
  var x;
  if (ids != null) {
    x = ids.map((i) => int.parse(i)).toList();
  } else {
    x = new List<int>();
  }
  return streamPosts(x, null);
}

Future<Stream<PostWidget>> getSavedPosts() async {
  return getPersistedPosts(_saved_pref_name);
}

Future<Stream<PostWidget>> getArchivedPosts() async {
  return getPersistedPosts(_archived_pref_name);
}

Future<List<String>> getPostIds(loc) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var ids = prefs.getStringList(loc);
  return ids;
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

deleteSavedPost(PostWidget pw) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var ids = prefs.getStringList(_saved_pref_name);

  if (ids != null) {
    ids.remove(pw.id.toString());
    prefs.setStringList(_saved_pref_name, ids);
  }
}

deleteArchivedPost(PostWidget pw) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var ids = prefs.getStringList(_archived_pref_name);

  if (ids != null) {
    ids.remove(pw.id.toString());
    prefs.setStringList(_archived_pref_name, ids);
  }
}
