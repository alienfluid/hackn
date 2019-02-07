import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'hnutils.dart';
import 'posts.dart';

printCommentThread(CommentThread t, int spaces) {
  String x = "";
  for (var i = 0; i < spaces; i++) {
    x += ' ';
  }
  print(x + shortenString(t.root.text));
  for (final c in t.children) {
    printCommentThread(c, spaces + 2);
  }
}

main() async {
  var x = new http.Client();
  var t = await fetchCommentThread(19104316, x);
  printCommentThread(t, 0);
}

/*
{
  "by" : "ricardobeat",
  "id" : 19100890,
  "kids" : [ 19101028 ],
  "parent" : 19100758,
  "text" : "Both solve state management issues, but really different goals.<p>Unstated has state containers as separate entities. This one is about seamlessly switching from a local useState hook to a context-based one with minimal code changes.<p>I’m not convinced it’s worth the hassle vs just creating your own contexts though. Here is the full source: <a href=\"https:&#x2F;&#x2F;github.com&#x2F;diegohaz&#x2F;constate&#x2F;blob&#x2F;master&#x2F;src&#x2F;index.tsx\" rel=\"nofollow\">https:&#x2F;&#x2F;github.com&#x2F;diegohaz&#x2F;constate&#x2F;blob&#x2F;master&#x2F;src&#x2F;index.t...</a>",
  "time" : 1549493047,
  "type" : "comment"
}
*/

class Comment {
  final String author;
  final int id;
  final List<int> kids;
  final int parent;
  final String text;
  final int time;
  final String type;

  Comment(
      {this.author,
      this.id,
      this.kids,
      this.parent,
      this.text,
      this.time,
      this.type});

  factory Comment.fromJson(Map<String, dynamic> json) {
    var k = json['kids'];
    var kids;
    if (k != null) {
      kids = new List<int>.from(k);
    } else {
      kids = new List<int>();
    }

    return Comment(
      author: json['by'],
      id: json['id'],
      time: json['time'],
      text: json['text'],
      type: json['type'],
      kids: kids,
      parent: json['parent'],
    );
  }
}

class CommentThread {
  Comment root;
  List<CommentThread> children;

  CommentThread() {
    root = new Comment();
    children = new List<CommentThread>();
  }
}

Future<Comment> fetchComment(id, httpClient) async {
  final response = await httpClient.get(
      'https://hacker-news.firebaseio.com/v0/item/' + id.toString() + ".json");

  if (response.statusCode == 200) {
    return Comment.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

Future<CommentThread> fetchCommentThread(id, httpClient) async {
  final response = await httpClient.get(
      'https://hacker-news.firebaseio.com/v0/item/' + id.toString() + ".json");

  CommentThread parent = new CommentThread();
  if (response.statusCode == 200) {
    parent.root = Comment.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }

  if (parent.root.kids != null && parent.root.kids.length > 0) {
    for (final c in parent.root.kids) {
      var x = await fetchCommentThread(c, httpClient);
      parent.children.add(x);
    }
  }

  return parent;
}

Stream<CommentThread> streamCommentThreads(List<int> ids) async* {
  var client = new http.Client();
  for (final id in ids) {
    var x = await fetchCommentThread(id, client);
    yield x;
  }
}

Future<Stream<CommentThread>> getComments(PostWidget p) async {
  if (p.kids != null && p.kids.length > 0) {
    return streamCommentThreads(p.kids);
  } else {
    return streamCommentThreads(new List<int>());
  }
}
