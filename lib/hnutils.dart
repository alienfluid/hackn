main () {
  print(shortenString("This is a test of a long string"));
  print(shortenString("short string"));
}

String shortenString(String s) {
  if (s.length > 40) {
    return s.substring(0, 37) + "...";
  } 
  return s;
}