abstract class ErrorMessageHandler {
  String generateErrorMessage(Object error);
}

class ErrorMessageHandlerImpl implements ErrorMessageHandler {
  @override
  String generateErrorMessage(Object error) {
    if (error is FormatException) {
      return 'Data format is not correct';
    }

    return error.toString();
  }
}
