import 'package:flutter/material.dart';
import 'posts.dart';

class ArchivedPage extends StatefulWidget {
  ArchivedPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ArchivedPageState createState() => _ArchivedPageState();
}

class _ArchivedPageState extends State<ArchivedPage> {
  var posts = <PostWidget>[];
  Widget makeBottom;
  ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    makeBottom = Container(
      height: 55.0,
      child: BottomAppBar(
        color: Colors.grey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
              },
            ),
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/saved');
              },
            ),
            IconButton(
              icon: Icon(Icons.archive, color: Colors.white),
              onPressed: scrollToTop,
            ),
          ],
        ),
      ),
    );

    loadPosts();
  }

 loadPosts() async {
    var p = await getArchivedPosts();
    if (p == null) {
      return;
    }
    print("got archived posts to load: " + p.length.toString());
    for (final x in p) {
      x.then((pw) {
        setState(() {
          posts.add(pw);
          posts.sort((a, b) => b.time.compareTo(a.time));
        });
      });
    }
  }

  Future<void> onRefresh() async {
    print("refreshed");
    setState(() {
      posts.clear();
      loadPosts();
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(0.0,
        curve: Curves.decelerate, duration: const Duration(milliseconds: 300));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Archived Posts"),
      ),
      body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            controller: _scrollController,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10.0),
            children: posts.map((p) {
                return Dismissible(
                    child: p,
                    key: new Key(p.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: new Container(
                        color: Colors.blueAccent,
                        child: Center(child: Text('No Action'))),
                    secondaryBackground: new Container(
                        color: Colors.blueGrey,
                        child: Center(child: Text('Unarchive'))),
                    onDismissed: (dir) {
                      if (dir == DismissDirection.startToEnd) {
                        print("no action");
                      } else {
                        posts.remove(p);
                        deleteArchivedPost(p);
                      }
                    });
              }).toList(),
          )),
      bottomNavigationBar: makeBottom,
    );
  }
}
