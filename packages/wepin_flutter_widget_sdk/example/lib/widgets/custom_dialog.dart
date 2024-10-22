import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String? title;
  final String message;
  final bool isError;
  final String? okButtonText;
  final VoidCallback? onOkPressed;

  const CustomDialog({
    Key? key,
    this.title,
    required this.message,
    this.isError = false,
    this.okButtonText,
    this.onOkPressed,
  })  : //assert(isError || (okButtonText != null && onOkPressed != null), 'okButtonText and onOkPressed must be provided when not an error.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.info_outline,
                color: isError ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title ?? (isError ? 'Error' : 'Information'),
                  style: TextStyle(
                    color: isError ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        height: 150, // Adjust the height as needed
        padding: const EdgeInsets.all(16.0), // Padding added around the content
        color: Colors.black, // Background color set to black
        child: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.white), // Text color set to white
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (onOkPressed != null) {
              onOkPressed!();
            }
            Navigator.of(context).pop();
          },
          child: Text(okButtonText ?? 'OK'),
        ),
      ],
    );
  }
}