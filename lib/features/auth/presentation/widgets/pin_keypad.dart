import 'package:flutter/material.dart';

/// A 0-9 + backspace numeric keypad for PIN entry.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  static const _layout = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'backspace'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _layout
          .map(
            (row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) => _buildKey(context, key)).toList(),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    if (key.isEmpty) {
      return const SizedBox(width: 72, height: 72);
    }
    if (key == 'backspace') {
      return SizedBox(
        width: 72,
        height: 72,
        child: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: onBackspacePressed,
        ),
      );
    }
    return SizedBox(
      width: 72,
      height: 72,
      child: TextButton(
        onPressed: () => onDigitPressed(key),
        child: Text(key, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
