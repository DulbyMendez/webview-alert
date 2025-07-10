// Widget personalizado para diálogos JavaScript
import 'package:flutter/material.dart';

class CustomJavaScriptDialog extends StatefulWidget {
  final String title;
  final String message;
  final String type; // 'alert', 'confirm', 'prompt'
  final String? confirmText;
  final String? defaultValue; // Para prompt
  final String? cancelText;
  final bool showCancelButton;
  final Function(String?)? onConfirm;
  final VoidCallback? onCancel;

  const CustomJavaScriptDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.confirmText,
    this.defaultValue,
    this.cancelText,
    this.showCancelButton = true,
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<CustomJavaScriptDialog> createState() => _CustomJavaScriptDialogState();
}

class _CustomJavaScriptDialogState extends State<CustomJavaScriptDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.defaultValue ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevenir cierre con botón atrás
      child: AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            if (widget.type == 'prompt') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                ),
                autofocus: true,
                // Eliminado onSubmitted para evitar doble cierre
              ),
            ],
          ],
        ),
        actions: _buildActions(),
      ),
    );
  }

  List<Widget> _buildActions() {
    switch (widget.type) {
      case 'alert':
        return [
          TextButton(
            onPressed: () {
              if (widget.onConfirm != null) {
                widget.onConfirm!(null);
              }
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ];

      case 'confirm':
        final actions = <Widget>[];

        if (widget.showCancelButton) {
          actions.add(
            TextButton(
              onPressed: () {
                if (widget.onCancel != null) {
                  widget.onCancel!();
                }
                Navigator.of(context).pop(false);
              },
              child: Text(widget.cancelText ?? 'Cancelar'),
            ),
          );
        }

        actions.add(
          TextButton(
            onPressed: () {
              if (widget.onConfirm != null) {
                widget.onConfirm!('true');
              }
              Navigator.of(context).pop(true);
            },
            child: Text(widget.confirmText ?? 'Aceptar'),
          ),
        );

        return actions;

      case 'prompt':
        final actions = <Widget>[];

        if (widget.showCancelButton) {
          actions.add(
            TextButton(
              onPressed: () {
                if (widget.onCancel != null) {
                  widget.onCancel!();
                }
              },
              child: Text(widget.cancelText ?? 'Cancelar'),
            ),
          );
        }

        actions.add(
          TextButton(
            onPressed: () {
              final value = _textController.text;
              if (widget.onConfirm != null) {
                widget.onConfirm!(value);
              }
            },
            child: const Text('Aceptar'),
          ),
        );

        return actions;
      default:
        return [
          TextButton(
            onPressed: () {
              if (widget.onConfirm != null) {
                widget.onConfirm!(null);
              }
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ];
    }
  }
}
