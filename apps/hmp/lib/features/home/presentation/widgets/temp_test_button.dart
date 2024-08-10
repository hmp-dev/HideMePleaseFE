import 'package:flutter/material.dart';
import 'package:mobile/app/core/notifications/notification_service.dart';

class TempTestButton extends StatefulWidget {
  const TempTestButton({super.key});

  @override
  State<TempTestButton> createState() => _TempTestButtonState();
}

class _TempTestButtonState extends State<TempTestButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 20),
      color: Colors.amberAccent,
      child: Column(
        children: [
          ElevatedButton(
            child: const Text("Test"),
            onPressed: () {
              NotificationServices.instance.initialize();
            },
          ),
        ],
      ),
    );
  }
}
