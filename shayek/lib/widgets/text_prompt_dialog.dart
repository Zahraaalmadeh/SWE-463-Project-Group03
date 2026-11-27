import 'package:flutter/material.dart';

/// Shows a dialog with one text field and returns the entered text, or null
/// if it was cancelled.
///
/// The dialog owns its [TextEditingController] and disposes it only when the
/// dialog is removed. Disposing it right after `showDialog` returns would
/// crash: the field is still on screen during the dialog's closing animation.
Future<String?> showTextPromptDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String initialText = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextPromptDialog(
      title: title,
      label: label,
      confirmLabel: confirmLabel,
      initialText: initialText,
    ),
  );
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.initialText,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String initialText;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
