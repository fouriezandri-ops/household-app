/// Persists and verifies the household PIN. Implementations decide where
/// the (hashed) PIN is stored — see [PinRepository] for the contract only.
abstract interface class PinRepository {
  /// Whether a PIN has ever been set on this device.
  Future<bool> hasPin();

  /// Hashes and stores [pin], replacing any existing one.
  Future<void> setPin(String pin);

  /// Returns true if [pin] matches the stored PIN. Returns false (rather
  /// than throwing) if no PIN has been set yet.
  Future<bool> verifyPin(String pin);

  /// Clears the stored PIN, returning the device to [AuthStatus.noPinSet].
  Future<void> clearPin();
}
