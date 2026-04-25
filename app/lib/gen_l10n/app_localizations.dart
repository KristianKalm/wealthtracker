import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_et.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  /// Prompt shown when user needs to enter their PIN
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// Error shown when an incorrect PIN is entered
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// Button label to switch to biometric authentication
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// Message shown on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Wealthtracker is Locked'**
  String get appIsLocked;

  /// Button label to unlock the app via biometrics
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Generic error message shown when an operation fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Error when the app version is not supported
  ///
  /// In en, this message translates to:
  /// **'App not supported'**
  String get appNotSupported;

  /// Error when the auth token is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid token'**
  String get invalidToken;

  /// Error when registering with an existing username
  ///
  /// In en, this message translates to:
  /// **'User already exists'**
  String get userAlreadyExists;

  /// Error when the user account is not found
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Error when a PIN is required but not provided
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get pinIsRequired;

  /// Error when login credentials are wrong
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// Error when the token is not found
  ///
  /// In en, this message translates to:
  /// **'Token not found'**
  String get tokenNotFound;

  /// Error when a file is not found
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// Success message when a file is saved
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get fileSaved;

  /// Success message when a file is deleted
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get fileDeleted;

  /// Error when OTA authenticator is already configured
  ///
  /// In en, this message translates to:
  /// **'Authenticator already set up'**
  String get otaAlreadySetUp;

  /// Error when there is no active OTA setup session
  ///
  /// In en, this message translates to:
  /// **'No ongoing authenticator setup'**
  String get otaNoOngoingSetup;

  /// Error when the OTA PIN is incorrect
  ///
  /// In en, this message translates to:
  /// **'Wrong authenticator PIN'**
  String get otaWrongPin;

  /// Success when OTA authenticator is confirmed
  ///
  /// In en, this message translates to:
  /// **'Authenticator confirmed'**
  String get otaConfirmed;

  /// Error when OTA authenticator has not been configured
  ///
  /// In en, this message translates to:
  /// **'Authenticator not set up'**
  String get otaNotSetUp;

  /// Success when OTA authenticator is removed
  ///
  /// In en, this message translates to:
  /// **'Authenticator removed'**
  String get otaRemoved;

  /// Success when the account is deleted
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// Success when the account is updated
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get accountUpdated;

  /// Error when a file path is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid path'**
  String get invalidPath;

  /// Error when the request timestamp has expired
  ///
  /// In en, this message translates to:
  /// **'Request expired'**
  String get timestampExpired;

  /// Error when the rate limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get tooManyRequests;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

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

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN Lock'**
  String get pinLock;

  /// No description provided for @syncSection.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncSection;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @setOneTimePassword.
  ///
  /// In en, this message translates to:
  /// **'Set one time password'**
  String get setOneTimePassword;

  /// No description provided for @tokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get tokens;

  /// No description provided for @changePasswordSetting.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordSetting;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @logOutSetting.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutSetting;

  /// No description provided for @localBackup.
  ///
  /// In en, this message translates to:
  /// **'Local Backup'**
  String get localBackup;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @changePinLabel.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinLabel;

  /// No description provided for @removePinLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get removePinLabel;

  /// No description provided for @setPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPinTitle;

  /// No description provided for @confirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPinTitle;

  /// No description provided for @pinsDidNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs did not match. Try again.'**
  String get pinsDidNotMatch;

  /// No description provided for @pinSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PIN set successfully'**
  String get pinSetSuccessfully;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutTitle;

  /// No description provided for @logOutConfirmLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'This will delete all local data and log you out. Your data is saved on the server and can be recovered by logging in again.'**
  String get logOutConfirmLoggedIn;

  /// No description provided for @logOutConfirmNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'This will delete all local data. This action cannot be undone.\n\nAre you sure you want to continue?'**
  String get logOutConfirmNotLoggedIn;

  /// No description provided for @logOutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutButton;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required.'**
  String get allFieldsRequired;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password. Check your current password.'**
  String get failedToChangePassword;

  /// No description provided for @accountDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account data not found.'**
  String get accountDataNotFound;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all data stored on the server. This action cannot be undone.\n\nEnter your password to confirm:'**
  String get deleteAccountMessage;

  /// No description provided for @failedToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Check your password.'**
  String get failedToDeleteAccount;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @debugTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debugTitle;

  /// No description provided for @apiTester.
  ///
  /// In en, this message translates to:
  /// **'API Tester'**
  String get apiTester;

  /// No description provided for @syncLastLessMinuteAgo.
  ///
  /// In en, this message translates to:
  /// **'Less than a minute ago'**
  String get syncLastLessMinuteAgo;

  /// Shows how many minutes ago the last sync happened
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} minute ago} other{{count} minutes ago}}'**
  String syncLastMinutesAgo(int count);

  /// Shows how many hours ago the last sync happened
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} hour ago} other{{count} hours ago}}'**
  String syncLastHoursAgo(int count);

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

  /// No description provided for @syncingTitle.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncingTitle;

  /// No description provided for @downloadingData.
  ///
  /// In en, this message translates to:
  /// **'Downloading your data...'**
  String get downloadingData;

  /// No description provided for @signedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in!'**
  String get signedInSuccessfully;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// No description provided for @keyGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Key generation failed'**
  String get keyGenerationFailed;

  /// No description provided for @backupYourSeed.
  ///
  /// In en, this message translates to:
  /// **'Backup Your Seed'**
  String get backupYourSeed;

  /// No description provided for @backupSeedMessage.
  ///
  /// In en, this message translates to:
  /// **'Make sure to backup this seed, this is the only way to recover your account!'**
  String get backupSeedMessage;

  /// No description provided for @seedCopied.
  ///
  /// In en, this message translates to:
  /// **'Seed copied to clipboard'**
  String get seedCopied;

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

  /// No description provided for @serverLabel.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverLabel;

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

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// Error when username is too short
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {min} characters.'**
  String usernameTooShort(int min);

  /// Error when username is too long
  ///
  /// In en, this message translates to:
  /// **'Username must be at most {max} characters.'**
  String usernameTooLong(int max);

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters.'**
  String passwordTooShort(int min);

  /// Error when password is too long
  ///
  /// In en, this message translates to:
  /// **'Password must be at most {max} characters.'**
  String passwordTooLong(int max);

  /// Helper text below the password field during registration
  ///
  /// In en, this message translates to:
  /// **'Password should be between {min} and {max} characters.'**
  String passwordHelperText(int min, int max);

  /// No description provided for @navMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get navMonth;

  /// No description provided for @navGraph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get navGraph;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @assetGroups.
  ///
  /// In en, this message translates to:
  /// **'Asset Groups'**
  String get assetGroups;

  /// No description provided for @importLegacyJson.
  ///
  /// In en, this message translates to:
  /// **'Import legacy JSON'**
  String get importLegacyJson;

  /// No description provided for @importLegacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exported data from wealthtracker.app/legacy'**
  String get importLegacySubtitle;

  /// No description provided for @hideLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideLabel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @failedToFetchTokens.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch tokens'**
  String get failedToFetchTokens;

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

  /// Success message after importing legacy data
  ///
  /// In en, this message translates to:
  /// **'Imported {count} items from legacy backup'**
  String importedLegacyItems(int count);

  /// No description provided for @backupShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Wealthtracker Backup'**
  String get backupShareSubject;

  /// Share text for the backup file
  ///
  /// In en, this message translates to:
  /// **'Your Wealthtracker backup from {date}'**
  String backupShareText(String date);

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

  /// No description provided for @otaFailedToGetSecret.
  ///
  /// In en, this message translates to:
  /// **'Failed to get OTA secret'**
  String get otaFailedToGetSecret;

  /// Error when user registration fails
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailed(String error);

  /// Generic error message with error details
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilities;

  /// Graph start date selector label
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String graphFrom(String date);

  /// Graph end date selector label
  ///
  /// In en, this message translates to:
  /// **'To {date}'**
  String graphTo(String date);

  /// No description provided for @noAssetsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No assets this month'**
  String get noAssetsThisMonth;

  /// No description provided for @noLiabilitiesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No liabilities this month'**
  String get noLiabilitiesThisMonth;

  /// No description provided for @noGroupsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No groups this month'**
  String get noGroupsThisMonth;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @commentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentTooltip;

  /// No description provided for @addAssetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAssetTooltip;

  /// No description provided for @noAssets.
  ///
  /// In en, this message translates to:
  /// **'No Assets'**
  String get noAssets;

  /// No description provided for @noAssetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click + to add an asset or liability for this month'**
  String get noAssetsSubtitle;

  /// Shows the change in asset value with a label
  ///
  /// In en, this message translates to:
  /// **'Change: {value}'**
  String changeValue(String value);

  /// Shows the previous month value for an asset suggestion
  ///
  /// In en, this message translates to:
  /// **'previous month: {value}'**
  String previousMonthValue(String value);

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get tapToAdd;

  /// Dialog title for the comment popup
  ///
  /// In en, this message translates to:
  /// **'Comment for {date}'**
  String commentForDate(String date);

  /// No description provided for @commentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentLabel;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get addComment;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No Tags Yet'**
  String get noTagsYet;

  /// No description provided for @noTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create tags to organize and categorize your assets'**
  String get noTagsSubtitle;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTag;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagName;

  /// No description provided for @enterTagName.
  ///
  /// In en, this message translates to:
  /// **'Enter tag name'**
  String get enterTagName;

  /// No description provided for @tagNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tag name cannot be empty'**
  String get tagNameEmpty;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroup;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No Asset Groups Yet'**
  String get noGroupsYet;

  /// No description provided for @noGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create groups to organize related assets together'**
  String get noGroupsSubtitle;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName;

  /// No description provided for @groupNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Group name cannot be empty'**
  String get groupNameEmpty;

  /// No description provided for @addNewAsset.
  ///
  /// In en, this message translates to:
  /// **'Add new asset'**
  String get addNewAsset;

  /// Dialog title when adding an asset suggestion to the current month
  ///
  /// In en, this message translates to:
  /// **'Add {name} to this month'**
  String addAssetToMonth(String name);

  /// Dialog title when editing an existing asset
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editAsset(String name);

  /// No description provided for @liability.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get liability;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupLabel;

  /// No description provided for @enterOrSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'Enter or select group'**
  String get enterOrSelectGroup;

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @changeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeFieldLabel;

  /// No description provided for @valueFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Value field must be filled'**
  String get valueFieldRequired;

  /// Option to delete only the selected month's asset value
  ///
  /// In en, this message translates to:
  /// **'Delete {month} value only'**
  String deleteMonthValueOnly(String month);

  /// Option to delete all monthly values for the asset
  ///
  /// In en, this message translates to:
  /// **'Delete all {name} values'**
  String deleteAllAssetValues(String name);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @autofill.
  ///
  /// In en, this message translates to:
  /// **'Autofill'**
  String get autofill;

  /// No description provided for @autofillFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get autofillFixed;

  /// No description provided for @autofillPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get autofillPercentage;

  /// No description provided for @autofillMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get autofillMonthly;

  /// No description provided for @autofillYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get autofillYearly;

  /// No description provided for @autofillMonthlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Monthly contribution'**
  String get autofillMonthlyContribution;

  /// No description provided for @autofillLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get autofillLoan;

  /// No description provided for @autofillLoanPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Loan amount'**
  String get autofillLoanPrincipal;

  /// No description provided for @autofillMonthlyPayment.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment'**
  String get autofillMonthlyPayment;

  /// No description provided for @autofillTotalWithInterest.
  ///
  /// In en, this message translates to:
  /// **'Total with interest'**
  String get autofillTotalWithInterest;

  /// No description provided for @autofillAmountPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Amount per month'**
  String get autofillAmountPerMonth;

  /// No description provided for @autofillRatePerMonth.
  ///
  /// In en, this message translates to:
  /// **'Rate per month (%)'**
  String get autofillRatePerMonth;

  /// No description provided for @autofillRatePerYear.
  ///
  /// In en, this message translates to:
  /// **'Rate per year (%)'**
  String get autofillRatePerYear;

  /// No description provided for @autofillLoanRate.
  ///
  /// In en, this message translates to:
  /// **'Annual interest rate (%)'**
  String get autofillLoanRate;

  /// No description provided for @autofillInitialAmount.
  ///
  /// In en, this message translates to:
  /// **'Initial amount'**
  String get autofillInitialAmount;

  /// No description provided for @autofillNumberOfMonths.
  ///
  /// In en, this message translates to:
  /// **'Number of months'**
  String get autofillNumberOfMonths;

  /// Label shown on autofill button when months have been configured
  ///
  /// In en, this message translates to:
  /// **'{count} months autofilled'**
  String autofillMonthsApplied(int count);

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @copyPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Copy previous month'**
  String get copyPreviousMonth;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus (net)'**
  String get bonus;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @addSalary.
  ///
  /// In en, this message translates to:
  /// **'Add salary'**
  String get addSalary;

  /// Dialog title for the salary popup
  ///
  /// In en, this message translates to:
  /// **'Salary for {date}'**
  String salaryFor(String date);

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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'et'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'et':
      return AppLocalizationsEt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
