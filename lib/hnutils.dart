import 'package:intl/intl.dart';

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
  DateTime d = new DateTime.fromMicrosecondsSinceEpoch(epoch);
  var format = new DateFormat("yMd");
  var dateString = format.format(d);
  return dateString;
}

String getHNUrl(int id) {
  return "https://news.ycombinator.com/item?id=" + id.toString();
}