import 'package:flutter/widgets.dart';
import 'package:wealthtracker/gen_l10n/app_localizations.dart';

export 'package:wealthtracker/gen_l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String fromCode(String code) {
    final l = l10n;
    switch (code) {
      case 'appNotSupported': return l.appNotSupported;
      case 'invalidToken': return l.invalidToken;
      case 'userAlreadyExists': return l.userAlreadyExists;
      case 'userNotFound': return l.userNotFound;
      case 'pinIsRequired': return l.pinIsRequired;
      case 'wrongPin': return l.wrongPin;
      case 'invalidCredentials': return l.invalidCredentials;
      case 'tokenNotFound': return l.tokenNotFound;
      case 'somethingWentWrong': return l.somethingWentWrong;
      case 'fileNotFound': return l.fileNotFound;
      case 'fileSaved': return l.fileSaved;
      case 'fileDeleted': return l.fileDeleted;
      case 'otaAlreadySetUp': return l.otaAlreadySetUp;
      case 'otaNoOngoingSetup': return l.otaNoOngoingSetup;
      case 'otaWrongPin': return l.otaWrongPin;
      case 'otaConfirmed': return l.otaConfirmed;
      case 'otaNotSetUp': return l.otaNotSetUp;
      case 'otaRemoved': return l.otaRemoved;
      case 'accountDeleted': return l.accountDeleted;
      case 'accountUpdated': return l.accountUpdated;
      case 'invalidPath': return l.invalidPath;
      case 'timestampExpired': return l.timestampExpired;
      case 'tooManyRequests': return l.tooManyRequests;
      default: return l.somethingWentWrong;
    }
  }
}
