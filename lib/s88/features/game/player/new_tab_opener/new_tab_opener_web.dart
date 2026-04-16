import 'package:web/web.dart' as web;

bool openNewTabDirectly(String url) {
  final popup = web.window.open(url, '_blank');
  return popup != null;
}
