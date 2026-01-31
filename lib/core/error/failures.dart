import 'package:equatable/equatable.dart';

/// ================= BASE FAILURE =================
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// ================= LOCAL DATABASE FAILURE =================
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = 'Local database operation failed',
  }) : super(message);
}

/// ================= API FAILURE =================
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// ================= SERVER FAILURE =================
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}

/// ================= NETWORK FAILURE =================
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
  }) : super(message);
}
