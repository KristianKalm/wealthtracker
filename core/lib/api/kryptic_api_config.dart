class KrypticApiConfig {
  final String appName;
  final String userSalt;
  final String passSalt;

  const KrypticApiConfig({
    required this.appName,
    required this.userSalt,
    required this.passSalt,
  });
}
