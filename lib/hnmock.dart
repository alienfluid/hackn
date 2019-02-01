import 'package:random_string/random_string.dart' as random;
import "posts.dart";

PostWidget generateRandom() {
  var headline = random.randomAlpha(int.parse(random.randomNumeric(2)));
  var url =
      "http://www." + random.randomAlpha(5) + ".com/" + random.randomAlpha(int.parse(random.randomNumeric(1)));
  var comments = int.parse(random.randomNumeric(2));
  var likes = int.parse(random.randomNumeric(3));

  return PostWidget(
      title: headline, url: url, score: comments, descendants: likes);
}

List<PostWidget> generateRandomNews(num) {
  List<PostWidget> l = new List(num);
  for (var i = 0; i < num; i++) {
    l[i] = generateRandom();
  }
  return l;
}