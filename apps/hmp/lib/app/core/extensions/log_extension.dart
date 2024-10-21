// import 'dart:developer' as devtools show log;

import 'package:flutter/foundation.dart';

// call log on string and pass StackTrace if want file Name  --> "here is log message".log(stackTrace: StackTrace.current);

/// Extension on Object to enable conditional logging in debug mode.
extension ObjectLog on Object {
  void log() {
    if (kDebugMode) {
      String callerInfo = StackTrace.current.toString().split('\n')[1];
      String location = callerInfo.substring(
          callerInfo.indexOf('package:'), callerInfo.length - 1);

      debugPrint(
          '🔑🔑🔑---------🪄️🪄️🪄️HideMePlease App Log Message----------🔑🔑🔑');
      debugPrint('📍📍📍 $location');
      debugPrint('');
      debugPrint('✍✍✍✍✍✍✍ Log Message: ${toString()}');
      debugPrint('');
      debugPrint('🔧🔧🔧--------------End of Log----------------🔧🔧🔧');
    }
  }
}
