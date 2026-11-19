import 'package:flutter/material.dart';

/// Xato matnini xato (error) rangida ko'rsatuvchi kichik widget.
class ErrorMessage extends StatelessWidget {
  const ErrorMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}
