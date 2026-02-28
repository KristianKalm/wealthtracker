
import 'package:flutter/cupertino.dart';
import '../gen_l10n/core_localizations.dart';

extension PaddingExtension on Widget {
  Widget withPadding([EdgeInsetsGeometry padding = const EdgeInsets.all(16)]) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}

extension VisibleIf on Widget {
  Widget visibleIf(bool isVisible) {
    return isVisible ? this : const SizedBox.shrink();
  }
}

extension CoreLocalizationsX on CoreLocalizations {
  String fromErrorCode(String code) {
    switch (code) {
      case 'appNotSupported': return errAppNotSupported;
      case 'invalidToken': return errInvalidToken;
      case 'userAlreadyExists': return errUserAlreadyExists;
      case 'userNotFound': return errUserNotFound;
      case 'pinIsRequired': return errPinIsRequired;
      case 'wrongPin': return errWrongPin;
      case 'invalidCredentials': return errInvalidCredentials;
      case 'tokenNotFound': return errTokenNotFound;
      case 'fileNotFound': return errFileNotFound;
      case 'fileSaved': return errFileSaved;
      case 'fileDeleted': return errFileDeleted;
      case 'otaAlreadySetUp': return errOtaAlreadySetUp;
      case 'otaNoOngoingSetup': return errOtaNoOngoingSetup;
      case 'otaWrongPin': return errOtaWrongPin;
      case 'otaConfirmed': return errOtaConfirmed;
      case 'otaNotSetUp': return errOtaNotSetUp;
      case 'otaRemoved': return errOtaRemoved;
      case 'accountDeleted': return errAccountDeleted;
      case 'accountUpdated': return errAccountUpdated;
      case 'invalidPath': return errInvalidPath;
      case 'timestampExpired': return errTimestampExpired;
      case 'tooManyRequests': return errTooManyRequests;
      default: return somethingWentWrong;
    }
  }
}
