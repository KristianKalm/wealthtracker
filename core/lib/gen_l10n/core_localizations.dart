import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'core_localizations_en.dart';
import 'core_localizations_et.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CoreLocalizations
/// returned by `CoreLocalizations.of(context)`.
///
/// Applications need to include `CoreLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/core_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CoreLocalizations.localizationsDelegates,
///   supportedLocales: CoreLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CoreLocalizations.supportedLocales
/// property.
abstract class CoreLocalizations {
  CoreLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CoreLocalizations? of(BuildContext context) {
    return Localizations.of<CoreLocalizations>(context, CoreLocalizations);
  }

  static const LocalizationsDelegate<CoreLocalizations> delegate =
      _CoreLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('et'),
  ];

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {min} characters.'**
  String usernameTooShort(int min);

  /// No description provided for @usernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Username must be at most {max} characters.'**
  String usernameTooLong(int max);

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters.'**
  String passwordTooShort(int min);

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password must be at most {max} characters.'**
  String passwordTooLong(int max);

  /// No description provided for @passwordHelperText.
  ///
  /// In en, this message translates to:
  /// **'Password should be between {min} and {max} characters.'**
  String passwordHelperText(int min, int max);

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// No description provided for @appIsLocked.
  ///
  /// In en, this message translates to:
  /// **'App is Locked'**
  String get appIsLocked;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @forgotPinLogOut.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN? Log out'**
  String get forgotPinLogOut;

  /// No description provided for @logOutConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? You will need to log in again.'**
  String get logOutConfirmPin;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @useWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Use without account'**
  String get useWithoutAccount;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account'**
  String get creatingAccount;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In'**
  String get signingIn;

  /// No description provided for @keyGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Key generation failed'**
  String get keyGenerationFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailed(String error);

  /// No description provided for @oneTimePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'One-Time Password'**
  String get oneTimePasswordTitle;

  /// No description provided for @oneTimePasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'One time password'**
  String get oneTimePasswordLabel;

  /// No description provided for @otaScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'One-Time Password'**
  String get otaScreenTitle;

  /// No description provided for @otaFailedToGetSecret.
  ///
  /// In en, this message translates to:
  /// **'Failed to get OTA secret'**
  String get otaFailedToGetSecret;

  /// No description provided for @otaIsEnabled.
  ///
  /// In en, this message translates to:
  /// **'One time password is enabled'**
  String get otaIsEnabled;

  /// No description provided for @otaTwoFactorProtected.
  ///
  /// In en, this message translates to:
  /// **'Your account is protected with two-factor authentication.'**
  String get otaTwoFactorProtected;

  /// No description provided for @otaEnterPasswordToRemove.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to remove:'**
  String get otaEnterPasswordToRemove;

  /// No description provided for @otaRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove one time password'**
  String get otaRemoveButton;

  /// No description provided for @otaScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your authenticator app'**
  String get otaScanQrCode;

  /// No description provided for @otaOrEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Or enter this key manually:'**
  String get otaOrEnterManually;

  /// No description provided for @otaKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Key copied to clipboard'**
  String get otaKeyCopied;

  /// No description provided for @otaEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code to confirm:'**
  String get otaEnterCode;

  /// No description provided for @otaEnabled.
  ///
  /// In en, this message translates to:
  /// **'One time password enabled'**
  String get otaEnabled;

  /// No description provided for @otaInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code, please try again'**
  String get otaInvalidCode;

  /// No description provided for @otaPasswordRemoved.
  ///
  /// In en, this message translates to:
  /// **'One time password removed'**
  String get otaPasswordRemoved;

  /// No description provided for @otaFailedToRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove. Check your password.'**
  String get otaFailedToRemove;

  /// No description provided for @tokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get tokens;

  /// No description provided for @failedToFetchTokens.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch tokens'**
  String get failedToFetchTokens;

  /// Generic error message with error details
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// No description provided for @noTokensFound.
  ///
  /// In en, this message translates to:
  /// **'No tokens found'**
  String get noTokensFound;

  /// No description provided for @unnamedToken.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Token'**
  String get unnamedToken;

  /// No description provided for @currentToken.
  ///
  /// In en, this message translates to:
  /// **'(current)'**
  String get currentToken;

  /// Shows when a token was created
  ///
  /// In en, this message translates to:
  /// **'Created: {timestamp}'**
  String tokenCreatedAt(String timestamp);

  /// Shows when a token was last used
  ///
  /// In en, this message translates to:
  /// **'Last used: {timestamp}'**
  String tokenLastUsedAt(String timestamp);

  /// No description provided for @tokenNeverUsed.
  ///
  /// In en, this message translates to:
  /// **'Never used'**
  String get tokenNeverUsed;

  /// No description provided for @deleteTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Token'**
  String get deleteTokenTitle;

  /// Confirmation dialog for deleting a token
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteTokenConfirm(String name);

  /// No description provided for @thisToken.
  ///
  /// In en, this message translates to:
  /// **'this token'**
  String get thisToken;

  /// No description provided for @tokenDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Token deleted successfully'**
  String get tokenDeletedSuccessfully;

  /// No description provided for @failedToDeleteToken.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete token'**
  String get failedToDeleteToken;

  /// No description provided for @errAppNotSupported.
  ///
  /// In en, this message translates to:
  /// **'App not supported'**
  String get errAppNotSupported;

  /// No description provided for @errInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid token'**
  String get errInvalidToken;

  /// No description provided for @errUserAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'User already exists'**
  String get errUserAlreadyExists;

  /// No description provided for @errUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get errUserNotFound;

  /// No description provided for @errPinIsRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get errPinIsRequired;

  /// No description provided for @errWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get errWrongPin;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get errInvalidCredentials;

  /// No description provided for @errTokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Token not found'**
  String get errTokenNotFound;

  /// No description provided for @errFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get errFileNotFound;

  /// No description provided for @errFileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get errFileSaved;

  /// No description provided for @errFileDeleted.
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get errFileDeleted;

  /// No description provided for @errOtaAlreadySetUp.
  ///
  /// In en, this message translates to:
  /// **'Authenticator already set up'**
  String get errOtaAlreadySetUp;

  /// No description provided for @errOtaNoOngoingSetup.
  ///
  /// In en, this message translates to:
  /// **'No ongoing authenticator setup'**
  String get errOtaNoOngoingSetup;

  /// No description provided for @errOtaWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong authenticator PIN'**
  String get errOtaWrongPin;

  /// No description provided for @errOtaConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Authenticator confirmed'**
  String get errOtaConfirmed;

  /// No description provided for @errOtaNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Authenticator not set up'**
  String get errOtaNotSetUp;

  /// No description provided for @errOtaRemoved.
  ///
  /// In en, this message translates to:
  /// **'Authenticator removed'**
  String get errOtaRemoved;

  /// No description provided for @errAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get errAccountDeleted;

  /// No description provided for @errAccountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get errAccountUpdated;

  /// No description provided for @errInvalidPath.
  ///
  /// In en, this message translates to:
  /// **'Invalid path'**
  String get errInvalidPath;

  /// No description provided for @errTimestampExpired.
  ///
  /// In en, this message translates to:
  /// **'Request expired'**
  String get errTimestampExpired;

  /// No description provided for @errTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get errTooManyRequests;

  /// No description provided for @captchaLabel.
  ///
  /// In en, this message translates to:
  /// **'Captcha'**
  String get captchaLabel;

  /// No description provided for @captchaInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid captcha'**
  String get captchaInvalid;

  /// No description provided for @captchaFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load captcha'**
  String get captchaFailedToLoad;

  /// No description provided for @serverLabel.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverLabel;

  /// No description provided for @serverNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get serverNotFound;

  /// Shows the server version number
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String serverVersionLabel(String version);

  /// No description provided for @checkServer.
  ///
  /// In en, this message translates to:
  /// **'Check Server'**
  String get checkServer;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;
}

class _CoreLocalizationsDelegate
    extends LocalizationsDelegate<CoreLocalizations> {
  const _CoreLocalizationsDelegate();

  @override
  Future<CoreLocalizations> load(Locale locale) {
    return SynchronousFuture<CoreLocalizations>(
      lookupCoreLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'et'].contains(locale.languageCode);

  @override
  bool shouldReload(_CoreLocalizationsDelegate old) => false;
}

CoreLocalizations lookupCoreLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CoreLocalizationsEn();
    case 'et':
      return CoreLocalizationsEt();
  }

  throw FlutterError(
    'CoreLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
