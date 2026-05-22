import 'new_tab_opener_stub.dart'
    if (dart.library.js_interop) 'new_tab_opener_web.dart';

bool openNewTab(String url) {
  return openNewTabDirectly(url);
}
