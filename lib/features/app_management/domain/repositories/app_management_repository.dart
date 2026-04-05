abstract class AppManagementRepository {
  /// Mark the app as done for the first time
  Future<void> doneFirstTime();

  /// Determine if the app is running for the first time
  Future<bool> determineFirstRun();
}
