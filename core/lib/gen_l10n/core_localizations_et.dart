// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class CoreLocalizationsEt extends CoreLocalizations {
  CoreLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get back => 'Tagasi';

  @override
  String get retry => 'Proovi uuesti';

  @override
  String get confirm => 'Kinnita';

  @override
  String get cancel => 'Tühista';

  @override
  String get delete => 'Kustuta';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Viga';

  @override
  String get pleaseWait => 'Palun ooda...';

  @override
  String get somethingWentWrong => 'Midagi läks valesti';

  @override
  String get changeButton => 'Muuda';

  @override
  String get language => 'Keel';

  @override
  String get usernameLabel => 'Kasutajanimi';

  @override
  String usernameTooShort(int min) {
    return 'Kasutajanimi peab olema vähemalt $min tähemärki.';
  }

  @override
  String usernameTooLong(int max) {
    return 'Kasutajanimi võib olla kuni $max tähemärki.';
  }

  @override
  String get passwordLabel => 'Parool';

  @override
  String passwordTooShort(int min) {
    return 'Parool peab olema vähemalt $min tähemärki.';
  }

  @override
  String passwordTooLong(int max) {
    return 'Parool võib olla kuni $max tähemärki.';
  }

  @override
  String passwordHelperText(int min, int max) {
    return 'Parool peaks olema $min kuni $max tähemärki.';
  }

  @override
  String get confirmNewPassword => 'Kinnita uus parool';

  @override
  String get newPasswordsDoNotMatch => 'Uued paroolid ei kattu.';

  @override
  String get enterPin => 'Sisesta PIN';

  @override
  String get wrongPin => 'Vale PIN';

  @override
  String get useBiometrics => 'Kasuta sõrmejälge';

  @override
  String get appIsLocked => 'Rakendus on lukustatud';

  @override
  String get unlock => 'Ava';

  @override
  String get loginButton => 'Logi sisse';

  @override
  String get registerButton => 'Registreeru';

  @override
  String get useWithoutAccount => 'Kasuta ilma kontota';

  @override
  String get creatingAccount => 'Konto loomine';

  @override
  String get signingIn => 'Sisselogimine';

  @override
  String get keyGenerationFailed => 'Võtme genereerimine ebaõnnestus';

  @override
  String registrationFailed(String error) {
    return 'Registreerimine ebaõnnestus: $error';
  }

  @override
  String get oneTimePasswordTitle => 'Ühekordne parool';

  @override
  String get oneTimePasswordLabel => 'Ühekordne parool';

  @override
  String get otaScreenTitle => 'Ühekordne parool';

  @override
  String get otaFailedToGetSecret => 'OTA saladuse hankimine ebaõnnestus';

  @override
  String get otaIsEnabled => 'Ühekordne parool on lubatud';

  @override
  String get otaTwoFactorProtected =>
      'Sinu konto on kaitstud kahefaktorilise autentimisega.';

  @override
  String get otaEnterPasswordToRemove => 'Sisesta eemaldamiseks oma parool:';

  @override
  String get otaRemoveButton => 'Eemalda ühekordne parool';

  @override
  String get otaScanQrCode => 'Skaneeri see QR-kood oma autentimisrakendusega';

  @override
  String get otaOrEnterManually => 'Või sisesta see võti käsitsi:';

  @override
  String get otaKeyCopied => 'Võti kopeeritud lõikelauale';

  @override
  String get otaEnterCode => 'Sisesta kinnitamiseks 6-kohaline kood:';

  @override
  String get otaEnabled => 'Ühekordne parool lubatud';

  @override
  String get otaInvalidCode => 'Vigane kood, palun proovi uuesti';

  @override
  String get otaPasswordRemoved => 'Ühekordne parool eemaldatud';

  @override
  String get otaFailedToRemove =>
      'Eemaldamine ebaõnnestus. Kontrolli oma parooli.';

  @override
  String get tokens => 'Pääsuload';

  @override
  String get failedToFetchTokens => 'Pääsuloadade laadimine ebaõnnestus';

  @override
  String anErrorOccurred(String error) {
    return 'Tekkis viga: $error';
  }

  @override
  String get noTokensFound => 'Pääsulube ei leitud';

  @override
  String get unnamedToken => 'Nimetu pääsuluba';

  @override
  String get currentToken => '(aktiivne)';

  @override
  String tokenCreatedAt(String timestamp) {
    return 'Loodud: $timestamp';
  }

  @override
  String tokenLastUsedAt(String timestamp) {
    return 'Viimati kasutatud: $timestamp';
  }

  @override
  String get deleteTokenTitle => 'Kustuta pääsuluba';

  @override
  String deleteTokenConfirm(String name) {
    return 'Kas oled kindel, et soovid kustutada $name?';
  }

  @override
  String get thisToken => 'seda pääsuluba';

  @override
  String get tokenDeletedSuccessfully => 'Pääsuluba edukalt kustutatud';

  @override
  String get failedToDeleteToken => 'Pääsuloa kustutamine ebaõnnestus';

  @override
  String get errAppNotSupported => 'Rakendus pole toetatud';

  @override
  String get errInvalidToken => 'Vigane pääsuluba';

  @override
  String get errUserAlreadyExists => 'Kasutaja on juba olemas';

  @override
  String get errUserNotFound => 'Kasutajat ei leitud';

  @override
  String get errPinIsRequired => 'PIN on kohustuslik';

  @override
  String get errWrongPin => 'Vale PIN';

  @override
  String get errInvalidCredentials => 'Valed sisselogimisandmed';

  @override
  String get errTokenNotFound => 'Pääsuluba ei leitud';

  @override
  String get errFileNotFound => 'Faili ei leitud';

  @override
  String get errFileSaved => 'Fail salvestatud';

  @override
  String get errFileDeleted => 'Fail kustutatud';

  @override
  String get errOtaAlreadySetUp => 'Autentija on juba seadistatud';

  @override
  String get errOtaNoOngoingSetup => 'Autentija seadistamine pole käimas';

  @override
  String get errOtaWrongPin => 'Vale autentija PIN';

  @override
  String get errOtaConfirmed => 'Autentija kinnitatud';

  @override
  String get errOtaNotSetUp => 'Autentija pole seadistatud';

  @override
  String get errOtaRemoved => 'Autentija eemaldatud';

  @override
  String get errAccountDeleted => 'Konto kustutatud';

  @override
  String get errAccountUpdated => 'Konto uuendatud';

  @override
  String get errInvalidPath => 'Vigane tee';

  @override
  String get errTimestampExpired => 'Päring aegunud';

  @override
  String get errTooManyRequests => 'Liiga palju päringuid';

  @override
  String get serverLabel => 'Server';

  @override
  String get serverNotFound => 'Ei leitud';

  @override
  String serverVersionLabel(String version) {
    return 'Versioon $version';
  }

  @override
  String get checkServer => 'Kontrolli serverit';

  @override
  String get continueButton => 'Jätka';
}
