import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:talker_logger/talker_logger.dart';

/// Enumeration for different log levels with their corresponding names.
///
/// Each log level has a specific priority and purpose:
/// - [debug]: For detailed information during development
/// - [info]: For general information messages
/// - [warning]: For potentially harmful situations
/// - [error]: For error events that still allow the application to continue
/// - [critical]: For serious error events that might abort the application
enum LogLevel {
  debug('DEBUG'),
  info('INFO'),
  warning('WARNING'),
  error('ERROR'),
  critical('CRITICAL');

  const LogLevel(this.name);
  final String name;
}

/// A singleton logger class that provides structured logging functionality
/// with different log levels and platform-specific formatting.
///
/// This class uses the singleton pattern to ensure only one instance
/// exists throughout the application lifecycle.
///
/// Example usage:
/// ```dart
/// final logger = AppLogger();
/// logger.debug('Debug message', 'MyClass');
/// logger.error('Error occurred', 'MyClass', stackTrace);
/// ```
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final TalkerLogger _talker = TalkerLogger();

  /// Controls whether logging is enabled based on debug mode
  static const bool _showLog = kDebugMode;

  /// Checks if the current platform is iOS
  static final bool _isIOS = Platform.isIOS;

  /// Returns the current timestamp in ISO 8601 format
  static String get _timestamp => DateTime.now().toIso8601String();

  /// Internal method to handle all logging operations.
  ///
  /// [message] - The message to be logged
  /// [level] - The log level (debug, info, warning, error, critical)
  /// [context] - Optional context name (defaults to 'SYSTEM')
  /// [stackTrace] - Optional stack trace for error logging
  /// [exception] - Optional exception object for critical logging
  void _log(
    Object? message,
    LogLevel level,
    String? context, {
    StackTrace? stackTrace,
    Object? exception,
  }) {
    if (!_showLog) return;

    final String contextName = context ?? 'SYSTEM';
    final String logName = '$contextName ${level.name} - $_timestamp';

    final StringBuffer buffer = StringBuffer();

    if (!_isIOS) {
      buffer.writeln(logName);
    }

    if (exception != null) {
      buffer.write('Exception: $exception');
      if (stackTrace != null) {
        buffer.write('\n$stackTrace');
      }
    } else if (message is Error) {
      buffer.write('Error: $message');
      if (message.stackTrace != null) {
        buffer.write('\n${message.stackTrace}');
      }
    } else {
      buffer.write(message);
    }

    final String finalMessage = buffer.toString();

    if (_isIOS) {
      dev.log(finalMessage, name: logName);
    } else {
      switch (level) {
        case LogLevel.debug:
        case LogLevel.info:
          _talker.info(finalMessage);
          break;
        case LogLevel.warning:
          _talker.warning(finalMessage);
          break;
        case LogLevel.error:
          _talker.error(finalMessage);
          break;
        case LogLevel.critical:
          _talker.critical(finalMessage);
          break;
      }
    }
  }

  /// Logs a debug message with optional context.
  ///
  /// Debug messages are used for detailed information during development.
  /// These logs are only shown in debug mode.
  ///
  /// Example usage:
  /// ```dart
  /// logger.debug('User clicked button', 'HomePage');
  ///
  /// [HomePage] [DEBUG] - 2023-04-08T14:30:00.000
  /// User clicked button
  /// ```
  void debug(Object? message, [String? context]) {
    _log(message, LogLevel.debug, context);
  }

  /// Logs an info message with optional context.
  ///
  /// Info messages are used for general information that might be
  /// useful for understanding application flow.
  ///
  /// Example usage:
  /// ```dart
  /// logger.info('User authenticated successfully', 'AuthService');
  ///
  /// [AuthService] [INFO] - 2023-04-08T14:30:00.000
  /// User authenticated successfully
  /// ```
  void info(Object? message, [String? context]) {
    _log(message, LogLevel.info, context);
  }

  /// Logs a warning message with optional context.
  ///
  /// Warning messages indicate potentially harmful situations
  /// that don't prevent the application from continuing.
  ///
  /// Example usage:
  /// ```dart
  /// logger.warning('API response time is high', 'NetworkService');
  ///
  /// [NetworkService] [WARNING] - 2023-04-08T14:30:00.000
  /// API response time is high
  /// ```
  void warning(Object? message, [String? context]) {
    _log(message, LogLevel.warning, context);
  }

  /// Logs an error message with optional context and stack trace.
  ///
  /// Error messages indicate error events that still allow the
  /// application to continue running.
  ///
  /// Example usage:
  /// ```dart
  /// logger.error('Failed to save data', 'DatabaseService', stackTrace);
  ///
  /// [DatabaseService] [ERROR] - 2023-04-08T14:30:00.000
  /// Failed to save data
  /// #0 DatabaseService.save (file:///path/to/database.dart:45:12)
  /// ```
  void error(Object? message, [String? context, StackTrace? stackTrace]) {
    _log(message, LogLevel.error, context, stackTrace: stackTrace);
  }

  /// Logs a critical error with exception and optional context and stack trace.
  ///
  /// Critical errors are serious error events that might cause the
  /// application to abort or become unstable.
  ///
  /// Example usage:
  /// ```dart
  /// logger.critical(exception, 'PaymentService', stackTrace);
  ///
  /// [PaymentService] [CRITICAL] - 2023-04-08T14:30:00.000
  /// Exception: Payment processing failed
  /// #0 PaymentService.processPayment (file:///path/to/payment.dart:78:9)
  /// ```
  void critical(Object? exception, [String? context, StackTrace? stackTrace]) {
    _log(
      null,
      LogLevel.critical,
      context,
      exception: exception,
      stackTrace: stackTrace,
    );
  }
}

/// Global instance of AppLogger for easy access
final AppLogger _logger = AppLogger();

/// Logs the given [message] with the provided [context] as a debug message
/// if logging is enabled.
///
/// This is a static convenience function for quick debug logging.
///
/// Example usage:
/// ```dart
/// logDebugStatic('Button pressed', 'HomePage');
///
/// [HomePage] [DEBUG] - 2023-04-08T14:30:00.000
/// Button pressed
/// ```
void logDebugStatic(Object? message, String context) {
  _logger.debug(message, context);
}

/// Logs the given [exception] with the provided [context] as an error message
/// if logging is enabled.
///
/// This is a static convenience function for quick error logging.
///
/// Example usage:
/// ```dart
/// logErrorStatic(Exception('Network error'), 'ApiService');
///
/// [ApiService] [ERROR] - 2023-04-08T14:30:00.000
/// Exception('Network error')
/// ```
void logErrorStatic(Object? exception, String context) {
  _logger.error(exception, context);
}

/// Callback function for external logging systems.
///
/// This function can be used as a callback for other logging systems
/// that need to integrate with AppLogger.
///
/// [message] - The message to be logged
/// [isError] - Whether this is an error message (defaults to false)
///
/// Example usage:
/// ```dart
/// someExternalLogger.setCallback(logWriterCallBack);
/// ```
void logWriterCallBack(String message, {bool isError = false}) {
  if (isError) {
    _logger.error(message, 'SYSTEM');
  } else {
    _logger.info(message, 'SYSTEM');
  }
}

/// An extension on [Object] that adds convenient logging functionality.
///
/// This extension allows any object to log messages using its runtime type
/// as the context automatically.
extension ObjectLogger on Object? {
  /// Cache for runtime type names to improve performance
  static final Map<Type, String> _typeCache = <Type, String>{};

  /// Gets the context name based on the object's runtime type
  String get _contextName {
    if (this == null) return 'NULL';

    final Type type = runtimeType;
    return _typeCache[type] ??= type.toString();
  }

  /// Logs an error message with optional exception and stack trace.
  ///
  /// The context will be automatically set to the object's runtime type.
  /// If logging is disabled, nothing will be logged.
  ///
  /// Example usage:
  /// ```dart
  /// class MyClass {
  ///   void someMethod() {
  ///     try {
  ///       // some operation
  ///     } catch (e, stackTrace) {
  ///       logError(e, stackTrace);
  ///     }
  ///   }
  /// }
  ///
  /// [MyClass] [ERROR] - 2023-04-08T14:30:00.000
  /// Exception: Something went wrong
  /// #0 MyClass.someMethod (file:///path/to/myclass.dart:15:7)
  /// ```
  void logError([Object? exception, StackTrace? stackTrace]) {
    _logger.error(
      exception ?? 'Unknown error occurred',
      _contextName,
      stackTrace,
    );
  }

  /// Logs a debug message using the object's runtime type as context.
  ///
  /// Debug messages are only shown in debug mode to avoid performance
  /// impact in release builds.
  ///
  /// Example usage:
  /// ```dart
  /// class MyClass {
  ///   void someMethod() {
  ///     logDebug('Method called with parameter: $param');
  ///   }
  /// }
  ///
  /// [MyClass] [DEBUG] - 2023-04-08T14:30:00.000
  /// Method called with parameter: example
  /// ```
  void logDebug(Object? message) {
    _logger.debug(message, _contextName);
  }

  /// Logs a warning message using the object's runtime type as context.
  ///
  /// Warning messages are only shown in debug mode and indicate
  /// potentially harmful situations.
  ///
  /// Example usage:
  /// ```dart
  /// class MyClass {
  ///   void someMethod() {
  ///     logWarning('Deprecated method called');
  ///   }
  /// }
  ///
  /// [MyClass] [WARNING] - 2023-04-08T14:30:00.000
  /// Deprecated method called
  /// ```
  void logWarning(Object? message) {
    if (!kDebugMode) return;

    _logger.warning(message, _contextName);
  }

  /// Logs an info message using the object's runtime type as context.
  ///
  /// Info messages are only shown in debug mode and provide general
  /// information about application flow.
  ///
  /// Example usage:
  /// ```dart
  /// class MyClass {
  ///   void someMethod() {
  ///     logInfo('Processing completed successfully');
  ///   }
  /// }
  ///
  /// [MyClass] [INFO] - 2023-04-08T14:30:00.000
  /// Processing completed successfully
  /// ```
  void logInfo(Object? message) {
    if (!kDebugMode) return;

    _logger.info(message, _contextName);
  }
}

/// An extension on [Future] that adds timing logging functionality.
///
/// This extension allows you to log the execution time of async operations
/// automatically, which is useful for performance monitoring.
extension FutureLogger<T> on Future<T> {
  /// Logs the execution time of a Future operation.
  ///
  /// This method wraps the Future execution with timing logs, showing
  /// when the operation starts, completes, or fails along with the duration.
  ///
  /// [operation] - Description of the operation being timed
  /// [context] - Optional context for the logs (defaults to null)
  ///
  /// Example usage:
  /// ```dart
  /// final result = await apiCall()
  ///   .logTimed('Fetch user data', 'ApiService');
  ///
  /// // Output:
  /// [ApiService] [DEBUG] - 2023-04-08T14:30:00.000
  /// Starting: Fetch user data
  ///
  /// [ApiService] [DEBUG] - 2023-04-08T14:30:01.245
  /// Completed: Fetch user data (1245ms)
  /// ```
  ///
  /// If an error occurs:
  /// ```dart
  /// [ApiService] [ERROR] - 2023-04-08T14:30:01.245
  /// Failed: Fetch user data (1245ms) - HttpException: Connection failed
  /// #0 ApiService.fetchUserData (file:///path/to/api.dart:23:5)
  /// ```
  Future<T> logTimed(String operation, [String? context]) async {
    if (!kDebugMode) return this;

    final stopwatch = Stopwatch()..start();
    final logger = AppLogger();

    try {
      logger.debug('Starting: $operation', context);
      final result = await this;
      stopwatch.stop();
      logger.debug(
        'Completed: $operation (${stopwatch.elapsedMilliseconds}ms)',
        context,
      );
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      logger.error(
        'Failed: $operation (${stopwatch.elapsedMilliseconds}ms) - $error',
        context,
        stackTrace,
      );
      rethrow;
    }
  }
}
