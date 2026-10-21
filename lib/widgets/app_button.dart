import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// When true the button is disabled and shows a progress spinner.
  /// Used by Activity 9 to block duplicate submissions while an
  /// asynchronous request is still pending.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = OutlinedButton.styleFrom(
      minimumSize: const Size(220, 50),
      foregroundColor: Theme.of(context).colorScheme.primary,
      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );

    // Disabled while loading so a second click cannot submit twice.
    final VoidCallback? handler = isLoading ? null : onPressed;

    if (isLoading) {
      return OutlinedButton.icon(
        onPressed: null,
        style: style,
        icon: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(label),
      );
    }

    if (icon == null) {
      return OutlinedButton(
        onPressed: handler,
        style: style,
        child: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: handler,
      style: style,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
