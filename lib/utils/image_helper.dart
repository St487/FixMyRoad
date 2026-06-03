import 'package:fix_my_road/utils/myconfig.dart';

class ImageHelper {
  static String getUrl(dynamic path) {
    if (path == null) return "";

    final p = path.toString().trim();

    if (p.isEmpty || p == "null") {
      return "";
    }

    if (p.startsWith("http://") || p.startsWith("https://")) {
      return p;
    }

    return "${MyConfig.myurl}/$p";
  }
}