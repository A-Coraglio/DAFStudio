import 'package:flutter/material.dart';

import 'error_messages.dart';

/// Shows any error as a short, friendly SnackBar. Use this in every action
/// handler instead of formatting the exception by hand.
void showErrorSnack(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(friendlyErrorMessage(error))),
  );
}
