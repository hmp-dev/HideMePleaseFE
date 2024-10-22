import 'package:flutter/material.dart';

class EmailLoginDialog extends StatefulWidget {
  final bool requirePassword; // Control whether to require password or not
  final Function onLogin; // Function that can take different parameters based on requirePassword

  const EmailLoginDialog({
    super.key,
    required this.onLogin,
    this.requirePassword = true, // Default is to require a password
  });

  @override
  EmailLoginDialogState createState() => EmailLoginDialogState();
}

class EmailLoginDialogState extends State<EmailLoginDialog> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Email Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) => email = value,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          if (widget.requirePassword)
            TextField(
              onChanged: (value) => password = value,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (widget.requirePassword) {
              widget.onLogin(email, password); // Call with email and password
            } else {
              widget.onLogin(email: email); // Call with email only
            }
            Navigator.of(context).pop();
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
