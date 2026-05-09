/// The four possible states of authentication.
enum AuthStatus {
  /// No PIN has been set yet — new install or PIN cleared.
  unauthenticated,

  /// PIN has been set but the user has not unlocked this session.
  locked,

  /// PIN setup flow is in progress.
  pinSetup,

  /// User is fully authenticated for this session.
  authenticated,
}
