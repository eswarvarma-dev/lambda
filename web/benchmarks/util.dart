library lambda.benchmarks.util;

import 'dart:html';
import 'dart:js' show context;

final _gc = context['gc'];

void gc() {
  if (_gc != null) {
    _gc.apply(const []);
  }
}

getIntParameter(String name) {
  return int.parse(getStringParameter(name), radix: 10);
}

getStringParameter(String name) {
  List<Element> els = document.querySelectorAll('input[name="${name}"]');
  String value;
  for (var i = 0; i < els.length; i++) {
    InputElement el = els[i];
    String type = el.type;
    if ((type != 'radio' && type != 'checkbox') || el.checked) {
      value = el.value;
      break;
    }
  }
  if (value == null || value.trim().isEmpty) {
    throw 'Could not find an input field with name ${name}';
  }
  return value;
}

bindAction(String selector, Function callback) {
  var el = document.querySelector(selector);
  el.on['click'].listen((_) {
    callback();
  });
}

microBenchmark(name, iterationCount, callback) {
  var durationName = '''${name}/${iterationCount}''';
  window.console.time(durationName);
  callback();
  window.console.timeEnd(durationName);
}

void windowProfile(String name) {
  window.console.profile(name);
}

void windowProfileEnd(String name) {
  window.console.profileEnd(name);
}

profile(create, destroy, name) {
  return () {
    windowProfile(name + ' w GC');
    var duration = 0;
    var count = 0;
    while (count++ < 150) {
      gc();
      var start = window.performance.now();
      create();
      duration += window.performance.now() - start;
      destroy();
    }
    windowProfileEnd(name + ' w GC');
    window.console.log(
        '''Iterations: ${ count}; time: ${ duration / count} ms / iteration''');
    windowProfile(name + ' w/o GC');
    duration = 0;
    count = 0;
    while (count++ < 150) {
      var start = window.performance.now();
      create();
      duration += window.performance.now() - start;
      destroy();
    }
    windowProfileEnd(name + ' w/o GC');
    window.console.log(
        '''Iterations: ${ count}; time: ${ duration / count} ms / iteration''');
  };
}
