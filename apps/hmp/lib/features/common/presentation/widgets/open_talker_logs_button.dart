import 'package:flutter/material.dart';
import 'package:mobile/app/core/router/values.dart';

class OpenTalkerLogsButton extends StatelessWidget {
  const OpenTalkerLogsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Log.error('Fatal Error Log');
          // Log.info('Info Log');
          // Log.debug('Debug Log');
          // Log.info('Info Log');
          // Log.trace('Trace Log');
          // Log.warning('Warning Log');
          // await Future.delayed(const Duration(seconds: 1));
          Navigator.pushNamed(context, Routes.talker);
        },
        icon: const Icon(
          Icons.document_scanner,
          color: Colors.white,
        ),
        label: const Text(
          'Open logs',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
