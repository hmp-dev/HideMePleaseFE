// import 'dart:developer' as devtools show log;

import 'package:flutter/foundation.dart';

// call log on string and pass StackTrace if want file Name  --> "here is log message".log(stackTrace: StackTrace.current);

/// Extension on Object to enable conditional logging in debug mode.
extension Log on Object {
  void log() {
    if (kDebugMode) {
      String callerInfo = StackTrace.current.toString().split('\n')[1];
      String location = callerInfo.substring(
          callerInfo.indexOf('package:'), callerInfo.length - 1);

      // Define ANSI escape codes for text formatting
      const String reset = '\x1B[0m'; // Reset all attributes
      const String colorGreen = '\x1B[32m';
      const String colorMagenta = '\x1B[35m';
      const String colorLightCyan = '\x1B[94m';

      debugPrint(
          '$colorGreen----------------🪄️🪄️🪄️HideMePlease App Log Message----------------$reset');
      print('🔑 $colorMagenta$location$reset');
      debugPrint('$colorLightCyan${toString()}$reset');
      debugPrint('');
      debugPrint(
          '$colorGreen--------------------------🔧🔧🔧🔧🔧---------------------------$reset');
    }
  }
}
