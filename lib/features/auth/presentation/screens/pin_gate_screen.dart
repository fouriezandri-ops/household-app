import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_status.dart';
import '../providers/auth_providers.dart';
import '../widgets/pin_dots.dart';
import '../widgets/pin_keypad.dart';

/// Full-screen PIN gate. Shown at `/pin`, outside the bottom-nav shell.
///
/// Handles both flows: first-run PIN creation (enter twice to confirm) and
/// normal unlock (enter once, verified against the stored hash). Once
/// [AuthController] reaches [AuthStatus.unlocked], the router's redirect
/// takes over and navigates away — this screen doesn't navigate itself.
class PinGateScreen extends ConsumerStatefulWidget {
  const PinGateScreen({super.key});

  @override
  ConsumerState<PinGateScreen> createState() => _PinGateScreenState();
}

class _PinGateScreenState extends ConsumerState<PinGateScreen> {
  static const _pinLength = 4;

  String _entered = '';
  String? _firstEntry;
  String? _errorMessage;
  bool _isSubmitting = false;

  void _onDigit(String digit) {
    if (_isSubmitting || _entered.length >= _pinLength) return;
    setState(() {
      _entered += digit;
      _errorMessage = null;
    });
    if (_entered.length == _pinLength) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _submit() async {
    final status = ref.read(authControllerProvider).value;
    setState(() => _isSubmitting = true);

    try {
      if (status == AuthStatus.noPinSet) {
        if (_firstEntry == null) {
          setState(() {
            _firstEntry = _entered;
            _entered = '';
            _isSubmitting = false;
          });
          return;
        }
        if (_firstEntry != _entered) {
          setState(() {
            _errorMessage = "PINs didn't match — try again";
            _firstEntry = null;
            _entered = '';
            _isSubmitting = false;
          });
          return;
        }
        await ref.read(authControllerProvider.notifier).createPin(_entered);
      } else {
        final isCorrect = await ref.read(authControllerProvider.notifier).unlock(_entered);
        if (!isCorrect) {
          setState(() {
            _errorMessage = 'Incorrect PIN';
            _entered = '';
            _isSubmitting = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong — please try again';
          _entered = '';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: authAsync.when(
          data: _buildContent,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
        ),
      ),
    );
  }

  Widget _buildContent(AuthStatus status) {
    final isCreating = status == AuthStatus.noPinSet;
    final title = !isCreating
        ? 'Enter your PIN'
        : (_firstEntry == null ? 'Create a PIN' : 'Confirm your PIN');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: _errorMessage == null
              ? null
              : Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
        ),
        const SizedBox(height: 32),
        PinDots(length: _pinLength, filled: _entered.length, hasError: _errorMessage != null),
        const SizedBox(height: 48),
        PinKeypad(onDigitPressed: _onDigit, onBackspacePressed: _onBackspace),
      ],
    );
  }
}
