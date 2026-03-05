// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CoreLocalizationsEn extends CoreLocalizations {
  CoreLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => 'Back';

  @override
  String get retry => 'Retry';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get changeButton => 'Change';

  @override
  String get language => 'Language';

  @override
  String get usernameLabel => 'Username';

  @override
  String usernameTooShort(int min) {
    return 'Username must be at least $min characters.';
  }

  @override
  String usernameTooLong(int max) {
    return 'Username must be at most $max characters.';
  }

  @override
  String get passwordLabel => 'Password';

  @override
  String passwordTooShort(int min) {
    return 'Password must be at least $min characters.';
  }

  @override
  String passwordTooLong(int max) {
    return 'Password must be at most $max characters.';
  }

  @override
  String passwordHelperText(int min, int max) {
    return 'Password should be between $min and $max characters.';
  }

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match.';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get appIsLocked => 'App is Locked';

  @override
  String get unlock => 'Unlock';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get useWithoutAccount => 'Use without account';

  @override
  String get creatingAccount => 'Creating Account';

  @override
  String get signingIn => 'Signing In';

  @override
  String get keyGenerationFailed => 'Key generation failed';

  @override
  String registrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get oneTimePasswordTitle => 'One-Time Password';

  @override
  String get oneTimePasswordLabel => 'One time password';

  @override
  String get otaScreenTitle => 'One-Time Password';

  @override
  String get otaFailedToGetSecret => 'Failed to get OTA secret';

  @override
  String get otaIsEnabled => 'One time password is enabled';

  @override
  String get otaTwoFactorProtected =>
      'Your account is protected with two-factor authentication.';

  @override
  String get otaEnterPasswordToRemove => 'Enter your password to remove:';

  @override
  String get otaRemoveButton => 'Remove one time password';

  @override
  String get otaScanQrCode => 'Scan this QR code with your authenticator app';

  @override
  String get otaOrEnterManually => 'Or enter this key manually:';

  @override
  String get otaKeyCopied => 'Key copied to clipboard';

  @override
  String get otaEnterCode => 'Enter the 6-digit code to confirm:';

  @override
  String get otaEnabled => 'One time password enabled';

  @override
  String get otaInvalidCode => 'Invalid code, please try again';

  @override
  String get otaPasswordRemoved => 'One time password removed';

  @override
  String get otaFailedToRemove => 'Failed to remove. Check your password.';

  @override
  String get tokens => 'Tokens';

  @override
  String get failedToFetchTokens => 'Failed to fetch tokens';

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get noTokensFound => 'No tokens found';

  @override
  String get unnamedToken => 'Unnamed Token';

  @override
  String get currentToken => '(current)';

  @override
  String tokenCreatedAt(String timestamp) {
    return 'Created: $timestamp';
  }

  @override
  String tokenLastUsedAt(String timestamp) {
    return 'Last used: $timestamp';
  }

  @override
  String get tokenNeverUsed => 'Never used';

  @override
  String get deleteTokenTitle => 'Delete Token';

  @override
  String deleteTokenConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get thisToken => 'this token';

  @override
  String get tokenDeletedSuccessfully => 'Token deleted successfully';

  @override
  String get failedToDeleteToken => 'Failed to delete token';

  @override
  String get errAppNotSupported => 'App not supported';

  @override
  String get errInvalidToken => 'Invalid token';

  @override
  String get errUserAlreadyExists => 'User already exists';

  @override
  String get errUserNotFound => 'User not found';

  @override
  String get errPinIsRequired => 'PIN is required';

  @override
  String get errWrongPin => 'Wrong PIN';

  @override
  String get errInvalidCredentials => 'Invalid credentials';

  @override
  String get errTokenNotFound => 'Token not found';

  @override
  String get errFileNotFound => 'File not found';

  @override
  String get errFileSaved => 'File saved';

  @override
  String get errFileDeleted => 'File deleted';

  @override
  String get errOtaAlreadySetUp => 'Authenticator already set up';

  @override
  String get errOtaNoOngoingSetup => 'No ongoing authenticator setup';

  @override
  String get errOtaWrongPin => 'Wrong authenticator PIN';

  @override
  String get errOtaConfirmed => 'Authenticator confirmed';

  @override
  String get errOtaNotSetUp => 'Authenticator not set up';

  @override
  String get errOtaRemoved => 'Authenticator removed';

  @override
  String get errAccountDeleted => 'Account deleted';

  @override
  String get errAccountUpdated => 'Account updated';

  @override
  String get errInvalidPath => 'Invalid path';

  @override
  String get errTimestampExpired => 'Request expired';

  @override
  String get errTooManyRequests => 'Too many requests';

  @override
  String get captchaLabel => 'Captcha';

  @override
  String get captchaInvalid => 'Invalid captcha';

  @override
  String get captchaFailedToLoad => 'Failed to load captcha';

  @override
  String get serverLabel => 'Server';

  @override
  String get serverNotFound => 'Not found';

  @override
  String serverVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkServer => 'Check Server';

  @override
  String get continueButton => 'Continue';
}
