/// The three states the PIN gate can be in.
enum AuthStatus {
  /// No PIN has ever been set on this device — show the "create a PIN" flow.
  noPinSet,

  /// A PIN exists but the app is locked — show the "enter PIN" flow.
  locked,

  /// A PIN exists and was verified this session.
  unlocked,
}
