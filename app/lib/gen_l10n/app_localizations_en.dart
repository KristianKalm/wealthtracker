// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get appIsLocked => 'Wealthtracker is Locked';

  @override
  String get unlock => 'Unlock';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get appNotSupported => 'App not supported';

  @override
  String get invalidToken => 'Invalid token';

  @override
  String get userAlreadyExists => 'User already exists';

  @override
  String get userNotFound => 'User not found';

  @override
  String get pinIsRequired => 'PIN is required';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get tokenNotFound => 'Token not found';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get fileSaved => 'File saved';

  @override
  String get fileDeleted => 'File deleted';

  @override
  String get otaAlreadySetUp => 'Authenticator already set up';

  @override
  String get otaNoOngoingSetup => 'No ongoing authenticator setup';

  @override
  String get otaWrongPin => 'Wrong authenticator PIN';

  @override
  String get otaConfirmed => 'Authenticator confirmed';

  @override
  String get otaNotSetUp => 'Authenticator not set up';

  @override
  String get otaRemoved => 'Authenticator removed';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get accountUpdated => 'Account updated';

  @override
  String get invalidPath => 'Invalid path';

  @override
  String get timestampExpired => 'Request expired';

  @override
  String get tooManyRequests => 'Too many requests';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get confirm => 'Confirm';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get user => 'User';

  @override
  String get storage => 'Storage';

  @override
  String get preferences => 'Preferences';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get appLock => 'App Lock';

  @override
  String get pinLock => 'PIN Lock';

  @override
  String get syncSection => 'Sync';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get setOneTimePassword => 'Set one time password';

  @override
  String get tokens => 'Tokens';

  @override
  String get changePasswordSetting => 'Change password';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get logOutSetting => 'Log out';

  @override
  String get localBackup => 'Local Backup';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get importBackup => 'Import backup';

  @override
  String get changePinLabel => 'Change PIN';

  @override
  String get removePinLabel => 'Remove PIN';

  @override
  String get setPinTitle => 'Set PIN';

  @override
  String get confirmPinTitle => 'Confirm PIN';

  @override
  String get pinsDidNotMatch => 'PINs did not match. Try again.';

  @override
  String get pinSetSuccessfully => 'PIN set successfully';

  @override
  String get logOutTitle => 'Log Out';

  @override
  String get logOutConfirmLoggedIn =>
      'This will delete all local data and log you out. Your data is saved on the server and can be recovered by logging in again.';

  @override
  String get logOutConfirmNotLoggedIn =>
      'This will delete all local data. This action cannot be undone.\n\nAre you sure you want to continue?';

  @override
  String get logOutButton => 'Log Out';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get allFieldsRequired => 'All fields are required.';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match.';

  @override
  String get changeButton => 'Change';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully.';

  @override
  String get failedToChangePassword =>
      'Failed to change password. Check your current password.';

  @override
  String get accountDataNotFound => 'Account data not found.';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountMessage =>
      'This will permanently delete your account and all data stored on the server. This action cannot be undone.\n\nEnter your password to confirm:';

  @override
  String get failedToDeleteAccount =>
      'Failed to delete account. Check your password.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get debugTitle => 'Debug';

  @override
  String get apiTester => 'API Tester';

  @override
  String get syncLastLessMinuteAgo => 'Less than a minute ago';

  @override
  String syncLastMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '$count minute ago',
    );
    return '$_temp0';
  }

  @override
  String syncLastHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '$count hour ago',
    );
    return '$_temp0';
  }

  @override
  String get creatingAccount => 'Creating Account';

  @override
  String get signingIn => 'Signing In';

  @override
  String get syncingTitle => 'Syncing';

  @override
  String get downloadingData => 'Downloading your data...';

  @override
  String get signedInSuccessfully => 'Successfully signed in!';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully!';

  @override
  String get keyGenerationFailed => 'Key generation failed';

  @override
  String get backupYourSeed => 'Backup Your Seed';

  @override
  String get backupSeedMessage =>
      'Make sure to backup this seed, this is the only way to recover your account!';

  @override
  String get seedCopied => 'Seed copied to clipboard';

  @override
  String get oneTimePasswordTitle => 'One-Time Password';

  @override
  String get oneTimePasswordLabel => 'One time password';

  @override
  String get serverLabel => 'Server';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get useWithoutAccount => 'Use without account';

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
  String get navMonth => 'Month';

  @override
  String get navGraph => 'Graph';

  @override
  String get navSettings => 'Settings';

  @override
  String get assetGroups => 'Asset Groups';

  @override
  String get importLegacyJson => 'Import legacy JSON';

  @override
  String get importLegacySubtitle =>
      'Exported data from wealthtracker.app/legacy';

  @override
  String get hideLabel => 'Hide';

  @override
  String get retry => 'Retry';

  @override
  String get tags => 'Tags';

  @override
  String get failedToFetchTokens => 'Failed to fetch tokens';

  @override
  String get tokenDeletedSuccessfully => 'Token deleted successfully';

  @override
  String get failedToDeleteToken => 'Failed to delete token';

  @override
  String get deleteTokenTitle => 'Delete Token';

  @override
  String deleteTokenConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get thisToken => 'this token';

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
  String importedLegacyItems(int count) {
    return 'Imported $count items from legacy backup';
  }

  @override
  String get backupShareSubject => 'Wealthtracker Backup';

  @override
  String backupShareText(String date) {
    return 'Your Wealthtracker backup from $date';
  }

  @override
  String get otaEnabled => 'One time password enabled';

  @override
  String get otaInvalidCode => 'Invalid code, please try again';

  @override
  String get otaPasswordRemoved => 'One time password removed';

  @override
  String get otaFailedToRemove => 'Failed to remove. Check your password.';

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
  String get otaFailedToGetSecret => 'Failed to get OTA secret';

  @override
  String registrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get assets => 'Assets';

  @override
  String get groups => 'Groups';

  @override
  String get liabilities => 'Liabilities';

  @override
  String graphFrom(String date) {
    return 'From $date';
  }

  @override
  String graphTo(String date) {
    return 'To $date';
  }

  @override
  String get noAssetsThisMonth => 'No assets this month';

  @override
  String get noLiabilitiesThisMonth => 'No liabilities this month';

  @override
  String get noGroupsThisMonth => 'No groups this month';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get commentTooltip => 'Comment';

  @override
  String get addAssetTooltip => 'Add Asset';

  @override
  String get noAssets => 'No Assets';

  @override
  String get noAssetsSubtitle =>
      'Click + to add an asset or liability for this month';

  @override
  String changeValue(String value) {
    return 'Change: $value';
  }

  @override
  String previousMonthValue(String value) {
    return 'previous month: $value';
  }

  @override
  String get tapToAdd => 'Tap to add';

  @override
  String commentForDate(String date) {
    return 'Comment for $date';
  }

  @override
  String get commentLabel => 'Comment';

  @override
  String get addComment => 'Add comment';

  @override
  String get addTag => 'Add Tag';

  @override
  String get noTagsYet => 'No Tags Yet';

  @override
  String get noTagsSubtitle =>
      'Create tags to organize and categorize your assets';

  @override
  String get editTag => 'Edit Tag';

  @override
  String get tagName => 'Tag Name';

  @override
  String get enterTagName => 'Enter tag name';

  @override
  String get tagNameEmpty => 'Tag name cannot be empty';

  @override
  String get addGroup => 'Add Group';

  @override
  String get noGroupsYet => 'No Asset Groups Yet';

  @override
  String get noGroupsSubtitle =>
      'Create groups to organize related assets together';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get groupName => 'Group Name';

  @override
  String get enterGroupName => 'Enter group name';

  @override
  String get groupNameEmpty => 'Group name cannot be empty';

  @override
  String get addNewAsset => 'Add new asset';

  @override
  String addAssetToMonth(String name) {
    return 'Add $name to this month';
  }

  @override
  String editAsset(String name) {
    return 'Edit $name';
  }

  @override
  String get liability => 'Liability';

  @override
  String get asset => 'Asset';

  @override
  String get nameLabel => 'Name';

  @override
  String get groupLabel => 'Group';

  @override
  String get enterOrSelectGroup => 'Enter or select group';

  @override
  String get valueLabel => 'Value';

  @override
  String get changeFieldLabel => 'Change';

  @override
  String get valueFieldRequired => 'Value field must be filled';

  @override
  String deleteMonthValueOnly(String month) {
    return 'Delete $month value only';
  }

  @override
  String deleteAllAssetValues(String name) {
    return 'Delete all $name values';
  }

  @override
  String get discard => 'Discard';

  @override
  String get autofill => 'Autofill';

  @override
  String get autofillFixed => 'Fixed';

  @override
  String get autofillPercentage => 'Percent';

  @override
  String get autofillMonthly => 'Monthly';

  @override
  String get autofillYearly => 'Yearly';

  @override
  String get autofillMonthlyContribution => 'Monthly contribution';

  @override
  String get autofillLoan => 'Loan';

  @override
  String get autofillLoanPrincipal => 'Loan amount';

  @override
  String get autofillTotalWithInterest => 'Total with interest';

  @override
  String get autofillAmountPerMonth => 'Amount per month';

  @override
  String get autofillRatePerMonth => 'Rate per month (%)';

  @override
  String get autofillRatePerYear => 'Rate per year (%)';

  @override
  String get autofillLoanRate => 'Annual interest rate (%)';

  @override
  String get autofillInitialAmount => 'Initial amount';

  @override
  String get autofillNumberOfMonths => 'Number of months';

  @override
  String autofillMonthsApplied(int count) {
    return '$count months autofilled';
  }

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
