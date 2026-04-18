import 'package:flutter/material.dart';

Widget errorMessageWidget(String? message, BuildContext context) {
  if (message == null) return const SizedBox(height: 18);

  return SizedBox(
    height: 18,
    child: Center(
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontFamily: 'Mplus1p',
          fontWeight: FontWeight.w300,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
