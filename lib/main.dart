import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'posts.dart';

void main() {
  debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackN',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'HackN - News Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
              onPressed: scrollToTop,
            ),
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.archive, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    listenForPosts();
  }

  listenForPosts() async {
    var stream = await getPosts();
    stream.listen((post) => post.then((p) => setState(() {
          posts.add(p);
          posts.sort((a, b) => b.score.compareTo(a.score));
        })));
  }

  Future<void> onRefresh() async {
    print("refreshed");
    setState(() {
      posts.clear();
      listenForPosts();
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
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            controller: _scrollController,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10.0),
            children: posts.toList(),
          )),
      bottomNavigationBar: makeBottom,
    );
  }
}
