import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

main() {
  print(shortenString("This is a test of a long string"));
  print(shortenString("short string"));
}

String shortenString(String s) {
  if (s.length > 48) {
    return s.substring(0, 45) + "...";
  }
  return s;
}

String getHumanTime(int epoch) {
  DateTime d = new DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  var format = new DateFormat.yMd().add_jm();
  var dateString = format.format(d);
  return dateString;
}

String getHNUrl(int id) {
  return "https://news.ycombinator.com/item?id=" + id.toString();
}

String getTimeAgo(int time) {
  return timeago.format(new DateTime.fromMillisecondsSinceEpoch(time * 1000));
}